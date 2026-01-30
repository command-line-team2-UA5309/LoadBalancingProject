import os
from flask import Flask, render_template

app = Flask(__name__)

bird_name = os.getenv("BIRD_NAME")
location = os.getenv("BIRD_LOCATION")
image = os.getenv("BIRD_IMAGE")

@app.route('/')
def main_page():
    return render_template('index.html', name=bird_name, location=location, image=image)


if __name__ == '__main__':
    app.run()
