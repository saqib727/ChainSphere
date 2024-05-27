import logo from "./logo.svg";
import Feed from "./pages/Feed";
import Home from "./pages/Home";
import { BrowserRouter as Router, Route, Routes } from "react-router-dom";
import Profile from "./pages/Profile";
import Signup from "./pages/Signup";
import Login from "./pages/Login";
import Post from "./pages/Post";
import { useSelector } from "react-redux";

function App() {
  const auth = useSelector((state) => state.auth);

  return (
    <Routes>
      <Route path="/" element={<Home />} />
      <Route path="/signup" element={<Signup />} />
      <Route path="/login" element={<Login />} />

      <Route path="/feed" element={auth.token ? <Feed /> : <Login />} />
      <Route path="/feed/trending" element={auth.token ? <Feed /> : <Login />} />
      <Route path="/post/:id" element={auth.token ? <Post /> : <Login />}  />
      <Route path="/profile"element={auth.token ? <Profile /> : <Login />} />
    </Routes>
  );
}

export default App;
