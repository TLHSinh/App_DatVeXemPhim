const upload_preset ='pic_sta_hospital';
const cloud_name = `sta-hospital`;


const uploadImageToCloudinary = async (file) => {
  const uploadData = new FormData();

  uploadData.append('file', file);
  uploadData.append('upload_preset', upload_preset);

  // You don't need to append 'cloud_name' to the body, it's part of the URL
  const res = await fetch(`https://api.cloudinary.com/v1_1/${cloud_name}/image/upload`, {
    method: 'POST',
    body: uploadData,
  });

  const data = await res.json(); // Correct the method call to json()
  return data;
};

export default uploadImageToCloudinary;
