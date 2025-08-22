from flask import Flask, request

app = Flask(__name__)

HTML_FORM = """
<!DOCTYPE html>
<html>
<head>
    <title>BMI Calculator</title>
</head>
<body style="font-family: Arial; text-align: center; margin-top: 50px;">
    <h2>BMI Calculator</h2>
    <form method="POST" action="/bmi-form">
        <label>Weight (kg):</label>
        <input type="text" name="weight" required><br><br>
        <label>Height (m):</label>
        <input type="text" name="height" required><br><br>
        <input type="submit" value="Calculate BMI">
    </form>
</body>
</html>
"""

@app.route("/")
def home():
    return HTML_FORM


# -----------------------------
# 1. POST endpoint (form submit)
# -----------------------------
@app.route("/bmi-form", methods=["POST"])
def bmi_form():
    try:
        weight = float(request.form["weight"])
        height = float(request.form["height"])
        bmi = weight / (height ** 2)

        if bmi < 18.5:
            category = "Underweight"
        elif 18.5 <= bmi < 24.9:
            category = "Normal weight"
        elif 25 <= bmi < 29.9:
            category = "Overweight"
        else:
            category = "Obesity"

        return f"""
        <h2>Your BMI Result</h2>
        <p>Weight: {weight} kg</p>
        <p>Height: {height} m</p>
        <p><b>BMI: {bmi:.2f}</b></p>
        <p>Category: {category}</p>
        <br><a href="/">Calculate Again</a>
        """
    except:
        return "<h3>Invalid input. Please enter valid numbers.</h3><br><a href='/'>Try Again</a>"


# -----------------------------
# 2. GET endpoint (API style)
# -----------------------------
@app.route("/bmi", methods=["GET"])
def bmi_get():
    try:
        weight = float(request.args.get("weight"))
        height = float(request.args.get("height"))
        bmi = weight / (height ** 2)

        if bmi < 18.5:
            category = "Underweight"
        elif 18.5 <= bmi < 24.9:
            category = "Normal weight"
        elif 25 <= bmi < 29.9:
            category = "Overweight"
        else:
            category = "Obesity"

        return {
            "weight": weight,
            "height": height,
            "bmi": round(bmi, 2),
            "category": category
        }
    except:
        return {"error": "Invalid input"}, 400


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
