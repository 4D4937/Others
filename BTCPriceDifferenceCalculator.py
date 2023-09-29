import requests

def get_btc_cny_price():
    url = "https://api.coingecko.com/api/v3/simple/price?ids=bitcoin&vs_currencies=cny"
    response = requests.get(url)
    if response.status_code == 200:
        data = response.json()
        btc_cny_price = data["bitcoin"]["cny"]
        return btc_cny_price
    else:
        print("Failed to retrieve BTC price in CNY.")
        return None

def calculate_investment_value(initial_investment, first_btc_price, second_btc_price, current_btc_price):
    btc_cny_price = get_btc_cny_price()
    if btc_cny_price is not None:
        first_btc_quantity = initial_investment / first_btc_price
        second_btc_quantity = initial_investment / second_btc_price
        first_btc_value = first_btc_quantity * btc_cny_price
        second_btc_value = second_btc_quantity * btc_cny_price
        value_difference = abs(first_btc_value - second_btc_value)
        first_btc_loss = round(((initial_investment - first_btc_value) / initial_investment) * 100, 2)
        second_btc_loss = round(((initial_investment - second_btc_value) / initial_investment) * 100, 2)

        # Print the formula results
        print("First BTC value:", round(first_btc_value, 2))
        print("Second BTC value:", round(second_btc_value, 2))
        print("Value difference:", round(value_difference, 2))
        print("First BTC loss:", first_btc_loss, "%")
        print("Second BTC loss:", second_btc_loss, "%")

        return value_difference

# Get input values from the user
initial_investment = float(input("Enter the initial investment amount: "))
first_btc_price = float(input("Enter the price of the first BTC: "))
second_btc_price = float(input("Enter the price of the second BTC: "))
current_btc_price = get_btc_cny_price()

if current_btc_price is not None:
    result = calculate_investment_value(initial_investment, first_btc_price, second_btc_price, current_btc_price)

input("Press Enter to exit the program")
