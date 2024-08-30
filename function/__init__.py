import logging
import azure.functions as func
import onnxruntime as ort
from PIL import Image
import numpy as np
import io

# Load the ONNX model
model_path = "model/resnet50.onnx"  # Ensure you place the ONNX model here
ort_session = ort.InferenceSession(model_path)

def preprocess_image(image: Image.Image) -> np.ndarray:
    image = image.resize((224, 224))
    img_data = np.array(image).astype('float32')
    img_data = img_data / 255.0
    img_data = np.transpose(img_data, [2, 0, 1])
    img_data = np.expand_dims(img_data, axis=0)
    return img_data

def main(req: func.HttpRequest) -> func.HttpResponse:
    logging.info('Image Inference Function triggered.')

    try:
        image_bytes = req.get_body()
        image = Image.open(io.BytesIO(image_bytes))
    except Exception as e:
        return func.HttpResponse(f"Invalid image data: {e}", status_code=400)

    img_data = preprocess_image(image)

    try:
        input_name = ort_session.get_inputs()[0].name
        result = ort_session.run(None, {input_name: img_data})
        prediction = np.argmax(result[0])
    except Exception as e:
        return func.HttpResponse(f"Inference failed: {e}", status_code=500)

    return func.HttpResponse(f"Predicted class: {prediction}", status_code=200)
