import jwt_decode from 'jwt-decode'

const authState = {
  userInfo: {},
  token: null
}

const tokenDecode = (token) => {
  const tokenDecoded = jwt_decode(token)

  const expTime = new Date(tokenDecoded.exp * 1000)
  if (new Date() > expTime) {
    return null
  }
  return tokenDecoded
}

const getToken = localStorage.getItem('token')

if (getToken) {
  const getInfo = tokenDecode(getToken)
  if (getInfo) {
    authState.token = getToken
    authState.userInfo = getInfo
  }
}

export const authReducer = (state = authState, action) => {
  const { payload, type } = action

  switch (type) {
    case 'USER_LOGIN_SUCCESS':
      const userInfo = tokenDecode(payload.token)
      return {
        ...state,
        userInfo: { ...userInfo, ...payload.userInfo },
        token: payload.token,
      }

    case 'REGISTER_SUCCESS':
      const userInfos = tokenDecode(payload.token)
      return {
        ...state,
        userInfo: { ...userInfos, ...payload.userInfo },
        token: payload.token,
      }
    case 'KYC_SUBMIT_SUCCESS':
      const kycUserInfo = tokenDecode(payload.token)
      return {
        ...state,
        userInfo: { ...kycUserInfo, ...payload.userInfo },
        token: payload.token,
      }
    case 'LOGOUT_SUCCESS':
      return {
        ...state,
        authenticate: false,
        userInfo: '',
        token: '',
        message: 'Logout Successful',
      }
    default:
      return state
  }
}
