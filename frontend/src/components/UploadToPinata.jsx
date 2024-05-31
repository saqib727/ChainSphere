import axios from 'axios';


export const uploadImageToPinata = async (file) => {
    const pinataApiKey = '8fa6f2e953d699922222';
const pinataSecretApiKey = 'dd35b370d484edca603edf496a1864da83eb991214402fe5affb79496665f47';

  const url = `https://api.pinata.cloud/pinning/pinFileToIPFS`;

  let data = new FormData();
  data.append('file', file);

  const response = await axios.post(url, data, {
    headers: {
      'Content-Type': `multipart/form-data; boundary=${data._boundary}`,
      pinata_api_key: pinataApiKey,
      pinata_secret_api_key: pinataSecretApiKey
    }
  });

  return response.data.IpfsHash;
};