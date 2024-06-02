import Navbar from "../components/Navbar";
import HeroSection from "../components/HeroSection";
import FeatureSection from "../components/FeatureSection";
import Workflow from "../components/Workflow";
import Footer from "../components/Footer";

import Testimonials from "../components/Testimonials";

const App = () => {
  return (
    <div style={{padding: "0 126px"}}>
      <Navbar />
      <div className=" mx-auto pt-20 px-6">
        <HeroSection />
        <FeatureSection />
        {/* <Workflow />

        <Testimonials />
        <Footer /> */}
      </div>
    </div>
  );
};

export default App;
