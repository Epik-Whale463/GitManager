import sys
from langchain_community.llms import Ollama
from langchain.prompts import PromptTemplate
from langchain.chains import LLMChain

def summarize_git_status(status_file):
    # Read the content of the status file
    with open(status_file, 'r') as file:
        status_content = file.read()

    # Initialize Ollama LLM
    llm = Ollama(model="llama3.2:1b")

    # Create a prompt template with strict focus on brevity
    prompt = PromptTemplate(
        input_variables=["status"],
        template=""" 100 percent Analyze every detail of the Git status and provide exactly:

1. Changed files (max 2 line if needed)
2. Next step (max 2 line if needed)

Output format:
Changes: [list only file names and if they are deleted or added or updated]
Action: [clear action]

Keep total response under 5 lines.
{status}"""
    )

    # Create an LLMChain
    chain = LLMChain(llm=llm, prompt=prompt)
    
    # Generate the summary
    summary = chain.run(status=status_content)
    return summary.strip()

def analyze_files_for_staging(status_file):
    with open(status_file, 'r') as file:
        status_content = file.read()

    llm = Ollama(model="llama3.2")
    
    prompt = PromptTemplate(
        input_variables=["status"],
        template="""Analyze Git status and provide:

Stage these files:
[file names only, 1 line per file]

Skip these files:
[file names only that should be ignored]

Keep total response under 6 lines, no explanations.
{status}"""
    )

    chain = LLMChain(llm=llm, prompt=prompt)
    
    try:
        analysis = chain.run(status=status_content)
        return analysis.strip()
    except Exception as e:
        return "Error: Could not analyze files."

def chat_with_llm():
    llm = Ollama(model="llama3.2")
    
    print("Welcome to Learn Git with GitLLM! Ask any questions about Git commands or type 'exit' to quit.")
    
    while True:
        user_input = input("You: ")
        if user_input.lower() == 'exit':
            print("Goodbye!")
            break
        
        prompt = PromptTemplate(
            input_variables=["user_query"],
            template="""Analyze the {user_query} and respond very friendly , the user is a beginner at github and all
            even though you are a master at all git and github and git commands you need to give simple and understading response.
            Never Explain in more than 5 lines ."""
        )
        
        chain = LLMChain(llm=llm, prompt=prompt)
        response = chain.run(user_query=user_input)
        
        print("GitLLM:", response.strip())

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python llm.py <status_file>")
        sys.exit(1)

    status_file = sys.argv[1]
    
    if status_file == "status.txt":
        summary = summarize_git_status(status_file)
    elif status_file == "add_files_analysis.txt":
        summary = analyze_files_for_staging("status.txt")
    elif status_file == "chat":
        chat_with_llm()
    else:
        print(f"Unknown file: {status_file}")
        sys.exit(1)

    # Write the summary to response.txt if applicable
    if 'summary' in locals():
        with open("response.txt", "w") as file:
            file.write(summary)
