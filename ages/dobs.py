from openai import OpenAI

API_KEY="<...>"
model="llama-3.1-sonar-large-128k-online"
client = OpenAI(api_key=API_KEY, base_url="https://api.perplexity.ai")

def get_dob(x):
  messages = [
      {
          "role": "system",
          "content": """
          You are a detailed research assistant helping the user find
          information about actors and actresses in movies and television. The 
          user will give you a name of an actor or actress—along with a movie
          or program they acted in—and it is your job to find the date of birth
          for that person. Finding an accurate date of birth is important 
          because the information will be employed by the user in a project 
          knowing this information is vital.
          
          You should respond in a very specific format: Four-digit year,
          two-digit month, and two-digit day, separated by dashes.
          
          For example, January 1st, 1990 should be returned as 1990-01-01. If
          only the year is available, it is acceptable to return only the year.
          
          Include no other text before or after the list; do not give any 
          commentary. Only list the date of birth for the actor or actress
          provided in the requested format.
          """,
      },
      {   
          "role": "user",
          "content": "stephen dorff, who acted in *somewhere*"
      },
      {   
          "role": "assistant",
          "content": "1973-07-29"
      },
      {   
          "role": "user",
          "content": "kristen schaal, who acted in *what we do in the shadows*"
      },
      {   
          "role": "assistant",
          "content": "1978-01-24"
      },
      {   
          "role": "user",
          "content": x
      },
  ]
  
  response = client.chat.completions.create(
    model=model, 
    messages=messages,
    temperature=0
  )
  
  return(response.choices[0].message.content)
