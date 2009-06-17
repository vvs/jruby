package org.jruby.compiler.ir;

public interface IR_BuilderContext
{
        // scripts
    public void addClass(IR_Class c);

        // scripts, classes, and modules
    public void addMethod(IR_Method m);

        // scripts, classes, modules, methods, and closures
    public void addInstr(IR_Instr i);

        // create a new variable
    public Variable getNewVariable();

        // create a new variable using the prefix
    public Variable getNewVariable(String prefix);

        // scripts
    public StringLiteral getFileName();
}