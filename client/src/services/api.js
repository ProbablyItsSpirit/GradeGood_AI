import axios from 'axios';
import { getAuth } from 'firebase/auth';

// Base URL for all API requests - update for production
const API_BASE_URL = process.env.NODE_ENV === 'production' 
  ? 'https://your-api-url.com'  // Replace with your deployed backend URL
  : 'http://localhost:8000';

// Create an axios instance with default config
const api = axios.create({
  baseURL: API_BASE_URL,
  headers: {
    'Content-Type': 'application/json',
  },
});

// Auth token interceptor ensures authenticated API requests
api.interceptors.request.use(async (config) => {
  const auth = getAuth();
  const user = auth.currentUser;
  
  if (user) {
    const token = await user.getIdToken();
    config.headers.Authorization = `Bearer ${token}`;
  }
  
  return config;
});

// The loginUser function handles communication with the backend
export const loginUser = async (userData) => {
  try {
    // Check if we're online first
    if (!navigator.onLine) {
      console.log("Device is offline, skipping backend login");
      
      // First ensure the user exists in Firestore
      try {
        const userRef = doc(db, "users", userData.uid);
        await setDoc(userRef, {
          email: userData.email,
          name: userData.name || userData.email.split('@')[0],
          role: userData.role,
          lastLogin: new Date(),
          updatedOffline: true
        }, { merge: true });
        console.log("Updated user data in Firestore while offline");
      } catch (firestoreError) {
        console.warn("Could not update Firestore while offline:", firestoreError);
      }
      
      return { 
        success: true, 
        message: "Logged in offline mode",
        offline: true,
        userData: userData
      };
    }
    
    console.log("Sending login request to backend");
    console.log("User data being sent:", {
      ...userData,
      uid: userData.uid.substring(0, 5) + '...' // Only log part of the UID for security
    });
    
    // Try the /auth/login endpoint first
    try {
      const response = await axios.post(`${API_BASE_URL}/auth/login`, userData, {
        // Add a timeout to prevent long hanging requests
        timeout: 5000,
        // Handle error responses properly
        validateStatus: function (status) {
          return status < 500; // Only reject if status code is 5xx
        }
      });
      console.log("Login successful with /auth/login endpoint");
      return response.data;
    } catch (authError) {
      console.error("Error with /auth/login endpoint:", authError);
      
      // Improved error handling - store user in Firestore directly if backend is unreachable
      try {
        const userRef = doc(db, "users", userData.uid);
        await setDoc(userRef, {
          email: userData.email,
          name: userData.name || userData.email.split('@')[0],
          role: userData.role,
          lastLoginAttempt: new Date(),
          backendUnavailable: true
        }, { merge: true });
        console.log("Stored user data directly in Firestore since backend is unavailable");
      } catch (firestoreError) {
        console.error("Could not store user data in Firestore either:", firestoreError);
      }
      
      return { 
        success: true, 
        message: "Logged in directly with Firebase (backend unavailable)",
        offline: true,
        userData: userData
      };
    }
  } catch (error) {
    console.error('Error during login/registration:', error);
    
    // Still try to update Firestore directly as a last resort
    try {
      const userRef = doc(db, "users", userData.uid);
      await setDoc(userRef, {
        email: userData.email,
        name: userData.name || userData.email.split('@')[0],
        role: userData.role,
        lastLoginError: new Date(),
        error: error.message
      }, { merge: true });
      console.log("Stored user data in Firestore despite errors");
      
      return { 
        success: true, 
        message: "Logged in with limited functionality",
        error: error.message,
        userData: userData
      };
    } catch (firestoreError) {
      console.error("Fatal error - could not communicate with any backend:", firestoreError);
    }
    
    // Provide more detailed error information based on response
    let errorMessage = "Unknown server error";
    
    if (error.response) {
      errorMessage = error.response.data?.detail || 
                    `Server error: ${error.response.status} ${error.response.statusText}`;
      console.error("Server response:", error.response.data);
    } else if (error.request) {
      errorMessage = "No response from server. Please check your connection.";
    } else {
      errorMessage = error.message;
    }
    
    throw new Error(errorMessage);
  }
};

// User Data
export const getUserData = async (userId) => {
  try {
    const response = await api.get(`/api/user/${userId}`);
    return response.data;
  } catch (error) {
    console.error('Error fetching user data:', error);
    throw error;
  }
};

// Classes
export const getClasses = async (userId) => {
  try {
    const response = await api.get(`/api/classes/${userId}`);
    return response.data;
  } catch (error) {
    console.error('Error fetching classes:', error);
    return [];
  }
};

// Assignments
export const getAssignments = async (userId) => {
  try {
    const response = await api.get(`/api/assignments/${userId}`);
    return response.data;
  } catch (error) {
    console.error('Error fetching assignments:', error);
    return [];
  }
};

// Assignment Submission
export const submitAssignment = async (userId, classId, file) => {
  try {
    const formData = new FormData();
    formData.append('file', file);
    formData.append('assignment_id', classId);
    formData.append('student_id', userId);
    
    const response = await axios.post(`${API_BASE_URL}/upload/answer_sheet`, formData, {
      headers: {
        'Content-Type': 'multipart/form-data',
      },
    });
    
    return response.data;
  } catch (error) {
    console.error('Error submitting assignment:', error);
    throw error;
  }
};

// Chat
export const sendChatMessage = async (userId, message) => {
  try {
    const response = await api.post('/api/chat', {
      message,
      student_id: userId
    });
    
    // Format the response for the chat UI
    return {
      id: Date.now(),
      sender: 'ai',
      message: response.data.response,
      timestamp: new Date().toISOString()
    };
  } catch (error) {
    console.error('Error sending chat message:', error);
    throw error;
  }
};

// Chat History
export const getChatHistory = async (userId) => {
  try {
    const response = await api.get(`/chat_history/${userId}`);
    
    // Transform the chat history into the format expected by the component
    return response.data.chat_history.map((chat, index) => ({
      id: index + 1,
      sender: 'user',
      message: chat.question,
      timestamp: chat.timestamp,
      response: {
        id: `r${index + 1}`,
        sender: 'ai',
        message: chat.answer,
        timestamp: chat.timestamp
      }
    })).flatMap(item => [
      item, 
      {
        id: `r${item.id}`,
        sender: 'ai',
        message: item.response.message,
        timestamp: item.timestamp
      }
    ]);
  } catch (error) {
    console.error('Error fetching chat history:', error);
    return [];
  }
};

// File Upload for Question Paper
export const uploadQuestionPaper = async (file, assignmentId) => {
  try {
    const formData = new FormData();
    formData.append('file', file);
    formData.append('assignment_id', assignmentId);
    
    const response = await axios.post(`${API_BASE_URL}/upload/question_paper`, formData, {
      headers: {
        'Content-Type': 'multipart/form-data',
      },
    });
    
    return response.data;
  } catch (error) {
    console.error('Error uploading question paper:', error);
    throw error;
  }
};

// File Upload for Solution
export const uploadSolution = async (file, assignmentId) => {
  try {
    const formData = new FormData();
    formData.append('file', file);
    formData.append('assignment_id', assignmentId);
    
    const response = await axios.post(`${API_BASE_URL}/upload/solution`, formData, {
      headers: {
        'Content-Type': 'multipart/form-data',
      },
    });
    
    return response.data;
  } catch (error) {
    console.error('Error uploading solution:', error);
    throw error;
  }
};

// Upload Audio for Speech-to-Text Processing
export const uploadAudio = async (file, studentId) => {
  try {
    const formData = new FormData();
    formData.append('file', file);
    formData.append('student_id', studentId);
    
    const response = await axios.post(`${API_BASE_URL}/upload_audio`, formData, {
      headers: {
        'Content-Type': 'multipart/form-data',
      },
    });
    
    return response.data;
  } catch (error) {
    console.error('Error uploading audio:', error);
    throw error;
  }
};

export default api;