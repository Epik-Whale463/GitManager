import sys
from langchain.llms import Ollama
from langchain.prompts import PromptTemplate
from langchain.chains import LLMChain

def summarize_git_status(status_file):
    # Read the content of the status file
    with open(status_file, 'r') as file:
        status_content = file.read()

    # Initialize Ollama LLM
    llm = Ollama(model="qwen2:1.5b")

    # Create a prompt template
    prompt = PromptTemplate(
        input_variables=["status"],
        template="""Analyze the following Git status and provide a structured summary:
        {status}
        Provide a concise, two-point summary focusing on:
        1. Changes: Briefly describe new, modified, or deleted files/folders.
        2. Action needed: Suggest the next step based on the current state, should be concise.
        Guidelines:
        - Use clear, concise English.
        - Focus on files and folders, not Git commands.
        - Be specific about the state of the workspace.
        - Provide intelligent insights beyond mere status repetition.
        - Maintain a helpful and informative tone.
        Example format:
        "1. Changes: [Brief description of changes]
        2. Action: [Suggested next step]"
        """
    )

    # Create an LLMChain
    chain = LLMChain(llm=llm, prompt=prompt)

    # Generate the summary
    summary = chain.run(status=status_content)
    return summary.strip()

def analyze_files_for_staging(status_file):
    with open(status_file, 'r') as file:
        status_content = file.read()
    
    print("Status Content for Analysis:")
    print(status_content)  # Debug print

    llm = Ollama(model="qwen2:1.5b")
    prompt = PromptTemplate(
        input_variables=["status"],
        template="""Analyze the following Git status and provide recommendations for staging files:
        {status}
        Please provide:
        1. A list of files that should be staged, with a brief explanation for each.
        2. Any files that should potentially be ignored, with reasons.
        3. General advice for the user about staging these changes.
        4. Answer should be in list points , and very concise and very understadable by a new commer and beginner.
        """
    )
    chain = LLMChain(llm=llm, prompt=prompt)
    
    try:
        analysis = chain.run(status=status_content)
        print("AI Analysis Output:")
        print(analysis)  # Debug print
        return analysis.strip()
    except Exception as e:
        print(f"Error in LLMChain execution: {e}")
        return "Error generating analysis."

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python llm.py <status_file>")
        sys.exit(1)

    status_file = sys.argv[1]
    
    if status_file == "status.txt":
        summary = summarize_git_status(status_file)
    elif status_file == "add_files_analysis.txt":
        summary = analyze_files_for_staging("status.txt")
    else:
        print(f"Unknown file: {status_file}")
        sys.exit(1)

    # Write the summary to response.txt
    with open("response.txt", "w") as file:
        file.write(summary)
    print("Analysis written to response.txt")