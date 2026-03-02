import gradio as gr
import requests

#Code for differentiation between running locally and API is based on Professor Paffenroth's Chatbot

api_url = "http://127.0.0.1:9005"

def respond(
    message,
    history,
    max_tokens,
    hf_token: gr.OAuthToken,
    use_local: bool,
):
    if use_local == True:
        #run local model
        
        data = {
            "message": message,
            "max_tokens": max_tokens,
        }

        #send post request
        response = requests.post(f"{api_url}/local", json=data)

        #check it was recieved
        if response.status_code == 200:
            print("Response:", response.text)
            
            yield response.text
        else:
            print("No response", response.status_code, response.text)

            yield "an error has occured"
    else:
        #run api model
        
        data = {
            "message": message,
            "max_tokens": max_tokens,
            "hf_token": hf_token.token,
        }

        #send post request
        response = requests.post(f"{api_url}/api", json=data)

        #check it was recieved
        if response.status_code == 200:
            print("Response:", response.text)
            
            yield response.text
        else:
            print("No response", response.status_code, response.text)

            yield "an error has occured"


chatbot = gr.ChatInterface(
    title="The Coffee Connoisseur",
    fn=respond,
    additional_inputs=[
        gr.Slider(minimum=1, maximum=2048, value=512, step=1, label="Max new tokens"),
        gr.Checkbox(label="Use Local Model?", value = False),
    ],
)

with gr.Blocks(title="Coffee Connoisseur", css="""
               body, * {
                    color: #795548;
                    font-family: "Comic Sans MS" !important;
                }

                body {
                    background-color: #F8BBD0;
                }

                .gr-chatbot, .gr-chat-message {
                    background-color: #BCAAA4 !important;
                    color: #795548 !important;
                    font-family: "Comic Sans MS" !important;
                }

                .gr-button {
                    background-color: #BCAAA4 !important;
                    color: #795548 !important;
                    font-family: "Comic Sans MS" !important;
                }

                .gr-slider .gr-slider-track, .gr-slider .gr-slider-thumb {
                    background-color: #BCAAA4 !important;
                }

                .gr-checkbox .gr-checkbox-label {
                    color: #795548 !important;
                    font-family: "Comic Sans MS" !important;
                }
               """) as demo:
    gr.Markdown(
        """
        <div>
        <strong>Instructions:</strong><br>
        Enter a taste profile for a desired coffee drink and the Coffee Connoisseur will recommend you a drink.<br>
        For best results, keep inputs short like "Floral and Delicate" or "Chocolatey and nutty".
        </div>
        """,
    )    
    
    with gr.Sidebar():
        gr.LoginButton()
    chatbot.render()


if __name__ == "__main__":
    demo.launch(server_name="0.0.0.0", server_port=7005)