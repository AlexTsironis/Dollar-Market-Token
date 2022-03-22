exchangeRates = [62.74, 100.772, 54.02, 52.11, 57.79, 52.355, 50.4, 46.6, 50.61, 50.25, 50.0, 52.0, 65.735, 50.49, 52.99, 52.8, 51.1, 51.05, 51.0, 52.12, 48.05, 45.26, 42.966, 48.0, 54.0, 52.17, 52.44, 53.79, 53.56, 52.327, 60.754, 57.0263, 58.48, 54.91, 52.32, 46.61, 48.13, 46.67, 44.4, 45.24, 46.04, 47.478, 44.69, 42.98, 41.49, 41.69, 41.02, 36.39, 36.31, 36.21, 34.65, 34.46, 33.66, 32.3181, 35.27, 37.11, 40.54, 45.33, 42.87, 48.06, 46.33, 46.89, 41.19, 41.8, 41.13, 41.68, 41.44, 36.35, 39.14, 37.9, 38.01, 41.0, 44.23, 45.43, 48.0, 50.04, 50.73, 48.09, 48.28, 51.71, 56.01, 54.2865, 57.959, 58.515, 62.74, 64.98, 69.33, 69.0177, 65.8, 68.907, 79.79, 74.91, 72.0, 78.81, 78.0, 80.52, 88.43, 80.7, 79.23, 81.36, 80.34, 85.09, 82.48, 85.6, 89.4, 89.8762, 96.03, 92.89, 107.5529, 100.145, 99.37, 105.6767, 93.51, 86.19, 73.44, 86.2805, 94.3, 118.1, 124.5, 125.63, 119.56, 130.008, 145.0, 87.85, 77.2, 86.75, 81.633, 90.41, 100.51, 94.901, 104.0, 108.76, 109.96, 123.3751, 122.57, 111.2, 102.3085, 106.0, 102.04, 104.99, 122.41, 83.47, 84.01, 51.24, 52.93, 53.64, 53.13, 52.29, 58.51, 47.3, 48.09, 47.004, 50.3198, 50.5, 46.96, 39.76, 43.39, 43.967, 45.94, 48.1, 59.03, 50.37, 59.4, 62.14, 65.54, 66.0, 63.0, 61.45, 59.41, 54.955, 56.88, 52.94, 53.52, 51.19, 51.31, 52.41, 53.09, 54.0, 49.99, 50.08, 47.5, 46.6, 45.743, 45.62, 47.7, 46.61, 44.91, 44.93, 43.22, 46.04, 52.05, 69.0, 82.81, 93.11, 87.0, 74.29, 72.968, 72.6, 65.95, 60.39, 49.105, 48.49, 48.94, 53.49, 51.5, 51.95, 55.1, 57.36, 54.59, 53.65, 48.66, 49.13, 44.65, 45.7, 48.7, 49.55, 46.88]
states = [[10000000000000000000000000, 10000000000000000000000000]]
transactions = []
def swapAMM(usd, tok, USD, TOK):
    usd, tok, USD, TOK = list(map(int, [usd, tok, USD, TOK]))
    if usd == 0:
	    return USD * tok // (TOK+tok)
    return TOK * usd // (USD+usd)

def binary(start, end, state):
    lft, rgh = 0, min(state)-1
    cur_exchange = state[0]/state[1]

    expected_exchange_rate = end / start * state[0]/state[1]
    
    while lft + 1 < rgh:
        #print(lft, rgh)
        mid = (lft + rgh)//2 + 1
           
        if end < start:
            quan = swapAMM(0, mid, state[0], state[1])
            new_state = [state[0]-quan, state[1]+mid]

            if abs(expected_exchange_rate - new_state[0]/new_state[1]) < 0.0000001:
                break
            
            if expected_exchange_rate > new_state[0]/new_state[1]:
                rgh = mid
            else:
                lft = mid
        else:
            quan = swapAMM(mid, 0, state[0], state[1])
            new_state = [state[0]+mid, state[1]-quan]
            #print(expected_exchange_rate, new_state[0]/new_state[1])
            if abs(expected_exchange_rate - new_state[0]/new_state[1]) < 0.0000001:
                break
            if expected_exchange_rate < new_state[0]/new_state[1]:
                rgh = mid
            else:
                lft = mid
    nT = [ new_state[0] - state[0], new_state[1] - state[1]]
    nT = [ max(0, nT[0]), max(0, nT[1])]
    mid = [0, mid] if end > start else [mid, 0]
    return nT, list(new_state)

for i in range(1, len(exchangeRates)):
    print(len(states))
    nT, nS = binary(exchangeRates[i-1], exchangeRates[i], states[-1])
    states.append(nS)
    transactions.append(nT)

transactions = [ [str(int(i[0])), str(int(i[1]))] for i in transactions]
model = [ i[0]/i[1] for i in states]
