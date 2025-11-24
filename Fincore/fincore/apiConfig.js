import { Platform } from 'react-native';

const TESTING_ON = 'device';

const SERVER_IPS = {
  AUTH_IP: '192.168.56.1',
  CONSENT_IP: '192.168.56.1',
  DATA_IP: '192.168.56.1',
  ADVISOR_IP: '192.168.56.1',
  INSIGHTS_IP: '192.168.56.1',
};

const getBaseUrl = (port, serverIP) => {
  if (TESTING_ON === 'emulator') return `http:
  if (TESTING_ON === 'simulator') return `http:
  return `http:
};

export const AUTH_BASE_URL = getBaseUrl(4000, SERVER_IPS.AUTH_IP);
export const CONSENT_BASE_URL = getBaseUrl(5000, SERVER_IPS.CONSENT_IP);
export const DATA_BASE_URL = getBaseUrl(6000, SERVER_IPS.DATA_IP);
export const ADVISOR_BASE_URL = getBaseUrl(7000, SERVER_IPS.ADVISOR_IP);
export const INSIGHTS_BASE_URL = getBaseUrl(8001, SERVER_IPS.INSIGHTS_IP);

export const API_ENDPOINTS = {

  LOGIN: `${AUTH_BASE_URL}/api/auth/login`,
  REGISTER: `${AUTH_BASE_URL}/api/auth/register`,
  VERIFY: `${AUTH_BASE_URL}/api/auth/verify`,

  CREATE_CONSENT: `${CONSENT_BASE_URL}/createConsent`,
  CHECK_USER_CONSENT: `${CONSENT_BASE_URL}/checkUserConsent`,
  CONSENT_CHECK: `${CONSENT_BASE_URL}/consentCheck`,
  SESSION_CHECK: `${CONSENT_BASE_URL}/sessionCheck`,
  GET_TRANSACTIONS: `${CONSENT_BASE_URL}/getTransactions`,
  GET_USER_ACCOUNTS: `${CONSENT_BASE_URL}/getUserAccounts`,
  GET_ACCOUNT_TRANSACTIONS: `${CONSENT_BASE_URL}/getAccountTransactions`,

  COMPANIES: `${DATA_BASE_URL}/companies`,
  HISTORY: `${DATA_BASE_URL}/historical_data`,
  GET_COMPANYS: `${AUTH_BASE_URL}/get_csv`,

  ADVISOR_LIST_CHATS: `${ADVISOR_BASE_URL}/advisor/chats/list`,
  ADVISOR_CREATE_CHAT: `${ADVISOR_BASE_URL}/advisor/chats/create`,
  ADVISOR_DELETE_CHAT: `${ADVISOR_BASE_URL}/advisor/chats/delete`,
  ADVISOR_LIST_MESSAGES: `${ADVISOR_BASE_URL}/advisor/messages/list`,
  ADVISOR_SEND_MESSAGE: `${ADVISOR_BASE_URL}/advisor/messages/send`,
  ADVISOR_HEALTH: `${ADVISOR_BASE_URL}/advisor/health`,

  INSIGHTS_GENERATE: `${INSIGHTS_BASE_URL}/insights/generate`,
  INSIGHTS_LIST: `${INSIGHTS_BASE_URL}/insights/list`,
  INSIGHTS_LATEST: `${INSIGHTS_BASE_URL}/insights/latest`,
  INSIGHTS_FINANCIAL_SUMMARY: `${INSIGHTS_BASE_URL}/insights/financial-summary`,
  INSIGHTS_HEALTH: `${INSIGHTS_BASE_URL}/insights/health`,
};

export default { AUTH_BASE_URL, CONSENT_BASE_URL, DATA_BASE_URL, ADVISOR_BASE_URL, INSIGHTS_BASE_URL, API_ENDPOINTS };