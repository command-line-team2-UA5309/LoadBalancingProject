from flask import Flask, render_template

app = Flask(__name__)

@app.route('/')
def hello() -> str:
    return render_template('woodpecker.html')


app.run()
