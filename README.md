# C-- Compiler 🔥

A simple compiler, made using flex and bison and coded in C, for a C-flavoured language we created called C--.  
This project has been made as a course project in the course CS-327: Compilers offered at IIT Gandhinagar in Semester-2 AY 2020-21 under the guidance of Prof. Bireswar Das. 

## Contributors ✏️

[Amey Kulkarni](https://github.com/amey-kulkarni27) (18110016), [Chris Francis](https://github.com/frank-chris) (18110041), [Aditya Pusalkar](https://github.com/AdityaPusalkar) (18110009)


## Table of Contents 📃

**[Requirements](#requirements-)**<br>
**[Compiling and Cleaning](#compiling-and-cleaning-%EF%B8%8F)**<br>
**[Usage](#usage-)**<br>
**[Features](#features-)**<br>
**[Files and Folders](#files-and-folders-)**<br>
**[References](#references-)**<br>


## Requirements ⚡

| Tool          | Version           
| ------------- |:-------------:
| flex          | 2.6.4
| bison         | 3.5.1      
| gcc           | 9.3.0
| MARS          | 4.5    
| GNU Make      | 4.2.1

### Flex and bison can be installed using  
```
sudo apt-get update
sudo apt-get upgrade
sudo apt-get install flex bison
```
### Verify installation 
```
flex --version
bison --version
```
### Mars can be installed by downloading from

[MARS Jar File](https://courses.missouristate.edu/KenVollmar/MARS/MARS_4_5_Aug2014/Mars4_5.jar)

### Run MARS using
```
java -jar Mars4_5.jar
```

### If you don't have Java, install using
```
sudo apt update
sudo apt install default-jre
sudo apt install default-jdk
```

### Verify installation
```
java -version
javac -version
```

## Compiling and cleaning ▶️

To compile, run
```
make
```

To clean, run
```
make clean
```

## Usage ⏩

To compile a program written in C-- using the compiler, run

```
./C<program_file_name 
```
The assembly output will be written to asmb.asm

To run the assembly code, use MARS.

## Features ⭐

### Variables
Variables can be declared and assigned as follows:
```C
a = 1;
```
There is no separate declaration for variables. The first time it appears will be taken as the declaration.

### Expressions

Complex expressions involving more than 2 terms are supported. Boolean expressions are also supported.

#### Arithmetic operators (+, -, *, /, %)

```C
a = 23;
b = 32;
c = (a + b) % 3;     // 1
d = a / b;           // 0
e = (a - c) * d;     // 0
```
#### Boolean values (true, false)

```C
a = true;
b = false;
```

#### Relational operators (>, <, >=, <=, ==, !=)

```C
a = 12;
b = 23;
c = a > b;            // false
d = a < b;            // true
e = b >= b;           // true
f = b <= a;           // false
g = a == a;           // true
h = a != a;           // false  
```

#### Logical operators (&, |, ^)

```C
a = false;
b = true;
c = a & b;       // false
d = a | b;       // true
e = a ^ c;       // false
```

### Loops - for, while, do while

For, while and do while loops and their nested variants are supported.

#### for

```C
a = 0;
for(i = 0; i < 10; i = i + 1)
{
    a = a + 2;
}
```

#### while

```C
a = 10;
while(a > 10)
{
    a = a - 1;
}
```

#### do while

```C
a = 10;
do
{
    a = a - 1;
}while(a > 10)
```

### Conditional - if else

If else and its nested variant is supported.

```C
a = 3;
b = 20;
c = 25;
if((a == 3) & (b < c))
{
    d = 20;
}
else
{
    if(a == 10)
    {
        d = 25;
    }
    else
    {
        d = 35;
    }
}
```

### Goto
```C
a = 23;
goto Label:
a = a + 2;
Label:
a = a + 3;      // a becomes 26, not 25
```


### Arrays

#### Array Declaration

Size of the array being declared can be an expression.
```C
a = 23;
b[a + 2];       // array of size 25 declared
```

#### Array Usage
```C
b[2] = 27;
d = b[2] + 3;   // d = 30
```

### Functions (recursion allowed)
Functions and recursive functions are supported. Parameters and return values also supported.
#### Function Declaration
```C
f(n){
    start       // start declaring local variables
    a = 1;
    b = 0;
    end         // stop declaring local variables
    if(n == 1){
        a = 1;
    }
    else{
        b = n - 1;
        b = f(b);
        a = b * n;
    }
    return a;
}
```

#### Function Call

Example for function call based on declaration shown above.
```C
x = f(5);   // x = 5! = 120
print(x);
```

### Function scope

Example:

```C
n = 20;
f(n){
    start       // start declaring local variables
    a = 1;
    end         // stop declaring local variables
    print(n);   // prints 40, not 20
    return a;
}

x = f(40);
```

### Output - print
Printing expressions is supported.
```C
a = 2;
b = 34;
print(a + b);   // prints 36
```

### Input - scan
Reading input into a variable is also supported.
```C
scan(a);    // takes input into a
```

## Files and Folders 📁

[`lexer.l`](https://github.com/frank-chris/Toy-C-Compiler/blob/main/lexer.l) - lexer  
[`parser.y`](https://github.com/frank-chris/Toy-C-Compiler/blob/main/parser.y) - parser     
[`parser.h`](https://github.com/frank-chris/Toy-C-Compiler/blob/main/parser.h) - header file  
[`expressions.c`](https://github.com/frank-chris/Toy-C-Compiler/blob/main/expressions.c) - code generation for expressions  
[`sym_operations.c`](https://github.com/frank-chris/Toy-C-Compiler/blob/main/sym_operations.c) - definitions of functions that use the symbol table  
[`func_operations.c`](https://github.com/frank-chris/Toy-C-Compiler/blob/main/func_operations.c) - definitions of functions that use the function table  
[`Makefile`](https://github.com/frank-chris/Toy-C-Compiler/blob/main/Makefile) - Makefile  
[`Tests`](https://github.com/frank-chris/Toy-C-Compiler/tree/main/Tests) - Folder containing test files  



## References 🔖

[1] [The Lex & Yacc Page](http://dinosaur.compilertools.net/)  
[2] [MIPS Instruction Set](https://www.dsi.unive.it/~gasparetto/materials/MIPS_Instruction_Set.pdf)
