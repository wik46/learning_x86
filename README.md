# learning_x86
This repository contains the source code for all my programs written to learn x86 assembly language.

# Resources used.
- Course name: CS271 at Oregon State University
- Course term: Winter 2021
- Textbook used: Irvine, Kip R., Assembly Language for x86 Processors.
- Assembler used: MASM
- IDE: Microsoft Visual Studio Enterprize 2019

## Instruction for setup with Microsoft Visual Studio (After installation of the Irvine library from his website http://asmirvine.com/gettingStartedVS2019/index.htm)
1. Open an empty project with Visual Studio.
2. Right click on main project file -> Build Dependancies -> Build Customizations -> MASM
3. Create a .asm file for your assembly source or copy one from this repository.
  - Make sure that 'item type' is set to Microsoft Macro Assembler.
  - If not, right click on the source file (.asm file) -> properties -> general -> and set item type.
4. Your project is now ready to build, but to add the Irvine32.inc library we need to perform a few more steps.
  - Make sure that the Irvine library folder is saved direclty under you c-drive.
5. Now to configure Visual Studio so that you executble file gets linked correctly.
  a. Go to the Irvine32.inc file, right click -> properties -> copy the file path.\n
  b. Right click on the solution -> properties - > linker -> Additional Library Directories -> paste the filepath.</br>
  c. Go to the linker settings -> Input -> Additional dependancies -> add the name of the library file to the front of the semi-colon
    seperated list (Irvine32.lib)\n
  d. (Still inside the properties tab) Microsoft Macro Assembler -> General -> Include Paths -> Include the path to the Irvine32.inc file (c:\Irvine )\n
  
  ** Note: I when including the Irvine library, my anti-virus software won't let me run the executable file. \n
            Solution = Add all the executables to the list of exeptions that your anti-virus software should not scan.\n
