# Numbering-System-Converter

This MIPS assembly project is designed to convert numbers between various numbering systems, including binary, octal, decimal, and hexadecimal.

Features:

Input:
# Number to be converted
  Source numbering system (binary, octal, decimal, or hexadecimal)
  Target numbering system (binary, octal, decimal, or hexadecimal)
  Conversion:
  Converts numbers from any supported system to any other supported system.
  Utilizes OtherToDecimal and DecimalToOther functions for efficient conversion.
  Output:
  Displays the converted number in the target system.
  Error Handling:
  Validates input numbers to ensure they belong to the specified source system.
  Displays an error message and exits if invalid input is detected.
# Usage:

# Compile and Run:
  Use a MIPS assembler (like MARS) to assemble the code.
  Run the generated executable file.
  Input:
  Enter the number to be converted.
  Enter the source numbering system (e.g., 2 for binary, 8 for octal, 10 for decimal, 16 for hexadecimal).
  Enter the target numbering system.
# Output:
  The converted number will be displayed in the target system.
  Implementation Details:

# OtherToDecimal Function:
  Converts a number from a given system to decimal.
  Uses a loop to iterate through each digit, multiplying by the appropriate power of the base and adding the result.
  DecimalToOther Function:
  Converts a decimal number to a given system.
  Uses a loop to repeatedly divide the decimal number by the base, storing the remainders as digits in the target system.
# Note:

  Ensure that the input numbers are valid for the specified source system.
  For optimal performance, consider using more efficient algorithms or hardware-accelerated instructions, if available.
