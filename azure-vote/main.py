from flask import Flask, request, render_template
import os
import random
import redis
import socket
import sys
import logging
from datetime import datetime

# App Insights
from opencensus.ext.azure.log_exporter import AzureEventHandler
from opencensus.ext.azure.log_exporter import AzureLogHandler
from opencensus.ext.azure import metrics_exporter

from opencensus.stats import aggregation as aggregation_module
from opencensus.stats import measure as measure_module
from opencensus.stats import stats as stats_module
from opencensus.stats import view as view_module
from opencensus.tags import tag_map as tag_map_module
from opencensus.trace import config_integration
from opencensus.trace.samplers import ProbabilitySampler
from opencensus.trace.tracer import Tracer
from opencensus.ext.flask.flask_middleware import FlaskMiddleware
from opencensus.ext.azure.trace_exporter import AzureExporter

APPLICATION_INSIGHTS_INTRUMENTATION_KEY = "InstrumentationKey=2a96864f-5ec9-4991-b433-7453fa08dd2a"

# Event Logging
logger = logging.getLogger(__name__)
logger.addHandler(AzureEventHandler(connection_string=APPLICATION_INSIGHTS_INTRUMENTATION_KEY))
logger.setLevel(logging.INFO)

# Metrics
exporter = metrics_exporter.new_metrics_exporter(enable_standard_metrics=True, connection_string=APPLICATION_INSIGHTS_INTRUMENTATION_KEY)

# Tracing
tracer = Tracer(exporter=AzureExporter(connection_string=APPLICATION_INSIGHTS_INTRUMENTATION_KEY), sampler=ProbabilitySampler(rate=1.0))


app = Flask(__name__)

# Requests: all (as sampler rate = 1) incoming requests sent to the flask application will be tracked.
middleware = FlaskMiddleware(app, exporter=AzureExporter(connection_string=APPLICATION_INSIGHTS_INTRUMENTATION_KEY), sampler=ProbabilitySampler(rate=1.0))

# Load configurations from environment or config file
app.config.from_pyfile("config_file.cfg")

if "VOTE1VALUE" in os.environ and os.environ["VOTE1VALUE"]:
    button1 = os.environ["VOTE1VALUE"]
else:
    button1 = app.config["VOTE1VALUE"]

if "VOTE2VALUE" in os.environ and os.environ["VOTE2VALUE"]:
    button2 = os.environ["VOTE2VALUE"]
else:
    button2 = app.config["VOTE2VALUE"]

if "TITLE" in os.environ and os.environ["TITLE"]:
    title = os.environ["TITLE"]
else:
    title = app.config["TITLE"]

# Redis Connection
# r = redis.Redis()
# Redis configurations
redis_server = os.environ["REDIS"]

# Redis Connection to another container
try:
    if "REDIS_PWD" in os.environ:
        r = redis.StrictRedis(host=redis_server, port=6379, password=os.environ["REDIS_PWD"])
    else:
        r = redis.Redis(redis_server)
    r.ping()
except redis.ConnectionError:
    exit("Failed to connect to Redis, terminating.")

# Change title to host name to demo NLB
if app.config["SHOWHOST"] == "true":
    title = socket.gethostname()

# Init Redis
if not r.get(button1):
    r.set(button1, 0)
if not r.get(button2):
    r.set(button2, 0)


@app.route("/", methods=["GET", "POST"])
def index():
    with tracer.span(name="app") as span:
        if request.method == "GET":

            # Get current values
            with tracer.span(name="get vote") as span:
                vote1 = r.get(button1).decode("utf-8")
                vote2 = r.get(button2).decode("utf-8")

            # Return index with values
            return render_template("index.html", value1=int(vote1), value2=int(vote2), button1=button1, button2=button2, title=title)

        elif request.method == "POST":
            if request.form["vote"] == "reset":

                # Empty table and return results
                with tracer.span(name="reset vote") as span:
                    r.set(button1, 0)
                    r.set(button2, 0)
                    vote1 = r.get(button1).decode("utf-8")
                    vote2 = r.get(button2).decode("utf-8")
                    logger.info(f"reset votes")

                return render_template("index.html", value1=int(vote1), value2=int(vote2), button1=button1, button2=button2, title=title)

            else:

                with tracer.span(name="post vote") as span:
                    # Insert vote result into DB
                    vote = request.form["vote"]
                    votes = r.incr(vote, 1)

                    properties = {"custom_dimensions": {f"{vote} votes": votes}}
                    logger.info(f"vote for {vote}", extra=properties)

                    # Get current values
                    vote1 = r.get(button1).decode("utf-8")
                    vote2 = r.get(button2).decode("utf-8")

                # Return results
                return render_template("index.html", value1=int(vote1), value2=int(vote2), button1=button1, button2=button2, title=title)


if __name__ == "__main__":
    # comment line below when deploying to VMSS
    # app.run()  # local
    # uncomment the line below before deployment to VMSS
    app.run(host="0.0.0.0", threaded=True, debug=True)  # remote
