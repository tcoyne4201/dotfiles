#!/usr/bin/env python3
"""
Example Python file to test debugging setup.
Use this to verify that debugging works with your uv virtual environment.
"""

def fibonacci(n: int) -> int:
    """Calculate the nth Fibonacci number."""
    if n <= 1:
        return n
    return fibonacci(n-1) + fibonacci(n-2)

def factorial(n: int) -> int:
    """Calculate the factorial of n."""
    if n <= 1:
        return 1
    return n * factorial(n-1)

def process_numbers(numbers: list[int]) -> dict[str, list[int]]:
    """Process a list of numbers and return fibonacci and factorial results."""
    results = {
        'fibonacci': [],
        'factorial': []
    }
    
    for num in numbers:
        fib_result = fibonacci(num)
        fact_result = factorial(num)
        
        results['fibonacci'].append(fib_result)
        results['factorial'].append(fact_result)
        
        print(f"Number: {num}, Fibonacci: {fib_result}, Factorial: {fact_result}")
    
    return results

def main():
    """Main function to test debugging."""
    print("Starting debug test...")
    
    # Test with some numbers
    test_numbers = [1, 2, 3, 4, 5]
    
    # Set a breakpoint on the next line to test debugging
    results = process_numbers(test_numbers)
    
    print("\nFinal results:")
    print(f"Fibonacci results: {results['fibonacci']}")
    print(f"Factorial results: {results['factorial']}")
    
    # Calculate sum of results
    fib_sum = sum(results['fibonacci'])
    fact_sum = sum(results['factorial'])
    
    print(f"\nSum of Fibonacci results: {fib_sum}")
    print(f"Sum of Factorial results: {fact_sum}")
    
    print("Debug test completed!")

if __name__ == "__main__":
    main()
