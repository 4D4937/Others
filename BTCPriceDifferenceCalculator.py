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
    first_btc_quantity = initial_investment / first_btc_price
    second_btc_quantity = initial_investment / second_btc_price
    btc_quantity_difference = abs(first_btc_quantity - second_btc_quantity)
    investment_value = btc_quantity_difference * current_btc_price
    
    # Print the formula results
    print("First BTC quantity:", first_btc_quantity)
    print("Second BTC quantity:", second_btc_quantity)
    print("BTC quantity difference:", btc_quantity_difference)
    print("BTC price difference:", investment_value)
    
    return investment_value

# Get input values from the user
initial_investment = float(input("Enter the initial investment amount: "))
first_btc_price = float(input("Enter the price of the first BTC: "))
second_btc_price = float(input("Enter the price of the second BTC: "))

btc_cny_price = get_btc_cny_price()
if btc_cny_price is not None:
    result = calculate_investment_value(initial_investment, first_btc_price, second_btc_price, btc_cny_price)

input("Press Enter to exit the program")