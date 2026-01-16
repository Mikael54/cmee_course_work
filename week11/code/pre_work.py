# to REDO

# Exercise 3B
# Exercise 1B

# Need a better understandbing of Q4B - i feel like we need context from something that he doesnt give us...



# Exercise 2
import numpy as np
import matplotlib.pyplot as plt

D = np.linspace(0.5, 5, 200)
T = np.linspace(0.5, 5, 200)

L = D**1.84
S = T**(-0.49)

plt.figure()
plt.plot(np.log(D), np.log(L))
plt.xlabel("Stem diameter D")
plt.ylabel("Leaf area L (k=1)")
plt.show()

plt.figure()
plt.plot(T, S)
plt.xlabel("Leaf thickness T")
plt.ylabel("Spongy mesophyll fraction S (c=1)")
plt.show()



# Exercise 3: Exponentials, logs, and half-lives.

import numpy as np

N0 = 1e8
h = 6.0
t = np.array([3,6,12], dtype=float)

N = N0*(0.5)**(t/h)
N

# Exercise 4: Oscillations and seasonality.

import numpy as np
import matplotlib.pyplot as plt

Z0, A, phi = 50, 20, 0
t = np.linspace(0, 24, 1000)  # months
omega = 2*np.pi/12

Z1 = Z0 + A*np.cos(omega*t + phi)
Z2 = Z0 + A*np.cos(2*omega*t + phi)

plt.figure()
plt.plot(t, Z1, label="omega")
plt.plot(t, Z2, label="2*omega")
plt.xlabel("t (months)")
plt.ylabel("Z(t)")
plt.legend()
plt.show()


## 3. Linear algebra (matrices, eigenvalues/eigenvectors)

# Exercise 1: Matrix multiplication in population transitions.

M = np.array([[0, 3], [0.2, 0.8]])
X = np.array([10, 5])

M @ X