# Define the dictionary
dict1 = {}

# Insert data into dictionary
dict1 = {1: ["Samuel", 81, 'Data Structures'],
         2: ["Richie", 90, 'Machine Learning'],
         3: ["Lauren", 71, 'OOPS with java'],
         }

# Print  names of the columns. 'NAME', 'Mark', 'COURSE'
print('NAME', 'Mark', 'COURSE')

# # print  data item.
for key, value in dict1.items():
    name, Mark, course = value
    print(name, Mark, course)

print(dict1[1])
print(dict1[2])
print(dict1[3])

for key, value in dict1.items():
    name, Mark, course = value
    print(dict1[key])

#     # print(value)
for key, value in dict1.items():
    name, Mark, course = value
    print(name)


# num1,num2= int(input("Enter two values: ").split()) 

# op = input("Enter operation:[* / + - ** ")

num1=2
num2=3
op= '+'

if op == '+':
    print(num1+num2)

elif op == '-':
    print(num1-num2)

elif op == '*':
    print(num1 * num2)

elif op == '/':
    print(num1 / num2)

elif op == '**':
    print(num1 ** num2)
elif op == '%':
    print(num1 % num2)


