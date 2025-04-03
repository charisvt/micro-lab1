#include <stdio.h>
#include "uart.h"

#define MAX_LENGTH 64
void read_uart(char *);
char input_buf[MAX_LENGTH];

extern unsigned int hash_result;
extern unsigned int fib_result;
extern unsigned int crc_result;

extern unsigned int hash(char *);
unsigned int hash_reference(char *str);

extern unsigned int modhash(unsigned int);
unsigned int modhash_reference(unsigned int);

extern unsigned int fibonacci(unsigned int h);
unsigned int fibonacci_reference(unsigned int h);

extern unsigned int crc(char *);
unsigned int crc_reference(char *);

void test_hash(char *input);
void test_modhash(unsigned int h);
void test_fib(unsigned int n);
void test_crc(char *);

int main(){
	
		test_hash("A9b3");			// Base case
		test_hash("Ab93");			// Reordered
		test_hash("93Ab");			// Reordered
		test_hash("A9b3?"); 		// Same chars with ignored symbol
		test_hash("??A9b3");		// More ignored symbols
		test_hash("");					// Empty string
		test_hash("123456789"); // All digits
		test_hash("aAbBzZ");		// Upper and lower case
		test_hash("AAaaBBbb");	// Repetitions
		test_hash("Hello123!"); // Alphanum + ignored
		test_hash("!@#$%^&*()");// Only ignored
	
		return 0;
}

unsigned int hash_reference(char *str) {
    unsigned int h = 0;
    
    // Compute length
    char *ptr = str;
    while (*ptr) {
        h++;
        ptr++;
    }

    // Digit lookup table
    unsigned int digit_table[] = {5, 12, 7, 6, 4, 11, 6, 3, 10, 23};

    // Process characters
    while (*str) {
        char c = *str++;

        if ('A' <= c && c <= 'Z') {
            h += c * 2;
        } else if ('a' <= c && c <= 'z') {
            unsigned int val = c - 'a';
            h += val * val;
        } else if ('0' <= c && c <= '9') {
            h += digit_table[c - '0'];
        }
        // Ignore other characters
    }

    return h;
}

unsigned int modhash_reference(unsigned int h){
		// Sum digits if needed
		if(h > 9){
				unsigned int sum = 0;
				while(h){
						// Exctract and add last digits
						sum += h % 10; 
						// Remove last digit
						h /= 10;
				}
				// Return hash mod7
				return sum % 7;
		}
		// Return original hash elsewise
		return h;
}

unsigned int fibonacci_reference(unsigned int n){
		if(n == 0)
			return 0;
		else if(n == 1)
			return 1;
		else
			return fibonacci(n-1) + fibonacci(n-2);
}

unsigned int crc_reference(char *str){
		// init checksum to 0
		unsigned int crc = 0;
		while(*str !=0){
				crc ^= *str;
				str++;
		}
		return crc;
}

// Test Hash Function
void test_hash(char *input) {
		//printf("Hash Function Test\n");
    unsigned int asm_result = hash(input);
    unsigned int c_result = hash_reference(input);
    printf("%-12s | %-6u | %-6u | HASH %s\n",
           input, asm_result, c_result, (asm_result == c_result) ? "PASSED" : "FAILED");
		test_crc(input);
		test_modhash(c_result);
}

// Test Modhash Function
void test_modhash(unsigned int h){
		unsigned int asm_result = modhash(h);
		unsigned int c_result = modhash_reference(h);
	  printf("%-12u | %-6u | %-6u | MODHASH %s\n",
           h, asm_result, c_result, (asm_result == c_result) ? "PASSED" : "FAILED");
		test_fib(c_result);
}

// Test Fibonacci Function
void test_fib(unsigned int n){
		unsigned int asm_result = fibonacci(n);
		unsigned int c_result = fibonacci_reference(n);
		printf("%-12u | %-6u | %-6u | FIB %s\n",
           n, asm_result, c_result, (asm_result == c_result) ? "PASSED" : "FAILED");
}

// Test crc Function
void test_crc(char *input){
		unsigned int asm_result = crc(input);
		unsigned int c_result = crc_reference(input);
		printf("%-12s | %-6u | %-6u | CRC %s\n",
           input, asm_result, c_result, (asm_result == c_result) ? "PASSED" : "FAILED");
}

// Not fully implemented yet
void read_uart(char *buf){
		size_t i = 0;
		uint8_t c;
		while(1){
				c = uart_rx(); // Blocking read
				if(c == '\r' || c == '\n'){
						buf[i] = '\0'; // Null terminate
						break;
				}else if(i < MAX_LENGTH -1){
						buf[i++] = c; // Store char
				}
		}
		
}