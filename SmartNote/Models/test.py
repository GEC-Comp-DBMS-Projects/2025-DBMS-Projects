from transformers import pipeline

summarizer = pipeline("summarization", model="Falconsai/text_summarization")

ARTICLE = """ 
Process Concept
A process, which is a program in execution. 
A process is the unit of work in a modern time-sharing system. A system therefore consists of a collection of processes: operating system processes executing system code and user processes executing user code. 
Potentially, all these processes can execute concurrently, with the CPU (or CPUs) multiplexed among them. 
By switching the CPU between processes, the operating system can make the computer
more productive.
A process is also known as a job or task. 
A process is more than the program code, which is sometimes known as the text section. 
It also includes the current activity, as represented by the value of the program counter and the contents of the processor’s registers. 
A process generally also includes the process stack, which contains temporary data (such as function parameters, return addresses, and local variables), and a data section, which contains global variables.

A program is a passive entity, such as a file containing a list of instructions stored on disk (often called an executable file). In contrast, a process is an active entity, with a program counter specifying the next instruction to execute and a set of associated resources.

"""
print(summarizer(ARTICLE, max_length=1000, min_length=300, do_sample=False))

