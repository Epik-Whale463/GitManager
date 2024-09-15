import sys
from langchain.llms import Ollama
from langchain.prompts import PromptTemplate
from langchain.chains import LLMChain

def summarize_git_status(status_file):
    # Read the content of the status file
    with open(status_file, 'r') as file:
        status_content = file.read()

    # Initialize Ollama LLM
    llm = Ollama(model="qwen2:0.5b")

    #prompt template for the LLM
 prompt = PromptTemplate(
        input_variables=["status"],
        template="""
        Given the following Git status information, provide a beginner-friendly summary:

        {status}

        Please summarize the current state of the Git repository in 2-3 short, simple sentences. Focus on:
        1. Whether there are any changes not yet committed (new, modified, or deleted files).
        2. Whether all changes are ready to be committed (staged) or if some still need to be added.
        3. If there's anything the user should do next (like committing changes or pushing to GitHub).

        Use simple language and avoid Git jargon where possible. If there's nothing to report, simply state that the repository is up to date.

        Remember, you're helping someone who is new to Git and GitHub.
        """
    )
    # Create an LLMChain
    chain = LLMChain(llm=llm, prompt=prompt)

    # Generate the summary
    summary = chain.run(status=status_content)

    return summary.strip()

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python llm.py <status_file>")
        sys.exit(1)

    status_file = sys.argv[1]
    summary = summarize_git_status(status_file)

    # Write the summary to response.txt
    with open("response.txt", "w") as file:
        file.write(summary)

    print("Summary written to response.txt")
