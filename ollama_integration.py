import ollama 
import argparse
import subprocess

client = ollama.Client()

parser = argparse.ArgumentParser(description='AI Security Insights')
parser.add_argument('--prompt', type=str, required=True, help='The prompt to send to the LLM')
args = parser.parse_args()

def choose_llm():
    #list of models user has installed on their machine
    list = ollama.list()
    model_names = []

    print("the models you have installed on your machine are:")
    i = 1
    for model in list['models']:
        name = model['model']
        print(f'{i} - {name}')
        model_names.append(name)
        i += 1
    
    #if no models are installed, prompt the user to install more or refer to user documentation
    if len(model_names) == 0:
        print("none!")
        print('if you would like to install the most optimal model for your hardware, please refer to the user documentation. \nthe models you can download here are less optimal but easier to install. would you like to install a model here? y/n')
        response = input().lower()
        
        while response not in ['y', 'n']:
            print('that was an invalid input, please input either y or n to proceed')
            response = input().lower()

        if response == 'n':
            user_selected_model = 0
            return user_selected_model

        if response == 'y':
            print('1) Deepseek-r1:8b (min spec 8gb vram, 16gb ram, and 7gb disk space)\n2) gpt-oss:20b (min spec 12gb vram, 16gb ram, and 15gb disk space)\n3) gemma3:270m (runs on anything, results are generally poor. use strictly for testing purposes)\n0) return to menu\n')
            print('If you do not meet minimum system requirements, you cannot run the locally hosted machines\n')
            print('input the index number next to your desired model')
            
            response = input()
            while response not in ['1', '2', '3', '0']:
                print('that was an invalid input, please input either 1, 2, 3, or 0 to proceed')
            
            if response == '1':
                print('installing, please wait. you will be prompted when the installation is complete.')
                subprocess.run(["ollama", "pull", "deepseek-r1:8b"], check=True)                
                user_selected_model = 'deepseek-r1:8b'
                return user_selected_model
                
            if response == '2':
                print('installing, please wait. you will be prompted when the installation is complete.')
                subprocess.run(["ollama", "pull", "gpt-oss:20b"], check=True)  
                user_selected_model = 'gpt-oss:20b'
                return user_selected_model
            
            if response == '3':
                print('installing, please wait. you will be prompted when the installation is complete.')
                subprocess.run(["ollama", "pull", "gemma3:270m"], check=True)  
                user_selected_model = 'gemma3:270m'
                return user_selected_model

            if response == '0':
                user_selected_model = 0
                return user_selected_model
    else: 
        #get user to select what model they want going to use
        print("\ninput the index number next to the model you would like to run: ")
        user_selected_model = input()
       
        while not user_selected_model.isdigit() or int(user_selected_model) not in range(1, len(model_names)+1):
            print("that was an invalid model, please input the index number next to the model you would like to run: ")
            user_selected_model = input()


        return model_names[int(user_selected_model) - 1]



def chat_with_llm(user_selected_model, prompt):
    if user_selected_model != 0:
        if user_selected_model == 'gpt-oss:20b':
            print("thinking mode provides more accurate results but the model will take longer produce a response.")
            think = input("would you like to enable thinking mode (y/n): ").lower()
            while think not in ['y', 'n']:
                think = input("that was an invalid input, please input either y or n: ").lower()

            if think == 'y':
                thinking_mode = True
            else:
                thinking_mode = False

        else:
            thinking_mode = False
        
        #submit prompt to that llm
        stream = ollama.chat(
            model = user_selected_model, 
            messages = [{
                'role': 'user',
                'content': prompt,
            }],
            think=thinking_mode,
            stream = True
        )
        #print(stream.message.content)
        #stream the response (streaming is to give a 'live output' rather than waiting for a bit and a large wall of text appearing)
        print("\n+-----------------------------+")
        print("|          Insights           |")
        print("+-----------------------------+")
        for chunk in stream:
            print(chunk['message']['content'], end='', flush=True)
        print("\n+-----------------------------+")
try: 
    user_selected_model = choose_llm()

    #very quick model - use for testing 
    #user_selected_model = "gemma3:270m"
    if user_selected_model != None:
        chat_with_llm(user_selected_model, args.prompt)

#most generic error handling possible
except Exception as e:
    print(f'An error occured: {e}')
