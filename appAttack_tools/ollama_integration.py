import ollama 
import argparse

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
        print('if you would like to install the most optimal model for your hardware, please refer to the user documentation. the models you can download here are less optimal but easier to install. would you like to install a model here? y/n')
        response = input().lower()
        
        while response not in ['y', 'n']:
            print('that was an invalid input, please input either y or n to proceed')
            response = input().lower()

        if response == 'n':
            user_selected_model = 0
            return user_selected_model

        if response == 'y':
            print('select model number 1 if you have at least 4gb vram, 16gb ram, and 7gb disk space. \nselect model number 2 if you have at least 12gb vram, 16gb ram, and 15gb disk space.\nIf you have neither, you cannot run the locally hosted machines. Type 3 to exit.\n')
            print('would you like to select model 1 or 2?')
            
            response = input()
            while response not in ['1', '2', '3']:
                print('that was an invalid input, please input either 1, 2, or 3 to proceed')
            
            if response == '1':
                print('installing, please wait. you will be prompted when the installation is complete.')
                ollama.pull('deepseek-r1:8b')
                user_selected_model = 'deepseek-r1:8b'
                return user_selected_model
                
            if response == '2':
                print('installing, please wait. you will be prompted when the installation is complete.')
                ollama.pull('gpt-oss:20b')
                user_selected_model = 'gpt-oss:20b'
                return user_selected_model

            if response == '3':
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
            thinking_mode = True
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
    else:
        print('You have no valid model. Please refer to the user documentation for more information')
try: 
    user_selected_model = choose_llm()

    #very quick model - use for testing 
    #user_selected_model = "gemma3:270m"
    if user_selected_model != None:
        chat_with_llm(user_selected_model, args.prompt)

#most generic error handling possible
except Exception as e:
    print(f'An error occured: {e}')
