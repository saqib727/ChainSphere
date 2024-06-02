import { features } from "../constants";
import { chainsphere } from "../constants";
import { chainsphere1 } from "../constants";
import { chainsphere2 } from "../constants";
const FeatureSection = () => {
  return (
    // 1
    <div className="relative mt-20 border-b border-neutral-800 min-h-[800px]">
      <div className="text-center">
        <span className="bg-neutral-900 text-orange-500 rounded-full h-6 text-md font-medium px-2 py-1 uppercase">
          Why Decentralized Social Media?
        </span>
        <h2 className="text-3xl sm:text-4xl lg:text-8xl mt-10 lg:mt-20 tracking-wide">
          Empowering Users with{" "}
          <span className="bg-gradient-to-r from-orange-500 to-orange-800 text-transparent bg-clip-text">
            True Ownership and Privacy
          </span>
        </h2>
      </div>

      <div className="flex flex-wrap mt-10 lg:mt-20">
        {features.map((feature, index) => (
          <div key={index} className="w-full sm:w-1/2 lg:w-1/3">
            <div className="flex">
              <div className="flex mx-6 h-20 w-20 p-2 bg-neutral-900 text-orange-700 justify-center items-center rounded-full">
                {feature.icon}
              </div>
              <div>
                <h5 className="mt-1 mb-6 text-3xl">{feature.text}</h5>
                <p className="text-3xl p-2 mb-20 text-neutral-500">
                  {feature.description}
                </p>
              </div>
            </div>
          </div>
        ))}
      </div>
      {/* 2 */}
      <div className="relative mt-20 border-b border-neutral-800 min-h-[800px]">
        <div className="text-center">
          <span className="bg-neutral-900 text-orange-500 rounded-full h-6 text-md font-medium px-2 py-1 uppercase">
            Why Choose Chain Sphere?
          </span>
          <h2 className="text-3xl sm:text-4xl lg:text-8xl mt-10 lg:mt-20 tracking-wide">
            Building on Polygon{" "}
            <span className="bg-gradient-to-r from-orange-500 to-orange-800 text-transparent bg-clip-text">
              for Unmatched Performance and Low Fees
            </span>
          </h2>
        </div>

        <div className="flex flex-wrap mt-10 lg:mt-20">
          {chainsphere.map((chainsphere, index) => (
            <div key={index} className="w-full sm:w-1/2 lg:w-1/3">
              <div className="flex">
                <div className="flex mx-6 h-20 w-20 p-2 bg-neutral-900 text-orange-700 justify-center items-center rounded-full">
                  {chainsphere.icon}
                </div>
                <div>
                  <h5 className="mt-1 mb-6 text-3xl">{chainsphere.text}</h5>
                  <p className="text-3xl p-2 mb-20 text-neutral-500">
                    {chainsphere.description}
                  </p>
                </div>
              </div>
            </div>
          ))}
        </div>

        {/* 3 */}

        <div className="relative mt-20 border-b border-neutral-800 min-h-[800px]">
          <div className="text-center">
            <span className="bg-neutral-900 text-orange-500 rounded-full h-6 text-md font-medium px-2 py-1 uppercase">
              Cutting-Edge Technology Integration
            </span>
            <h2 className="text-3xl sm:text-4xl lg:text-8xl mt-10 lg:mt-20 tracking-wide">
              Leveraging Chainlink for{" "}
              <span className="bg-gradient-to-r from-orange-500 to-orange-800 text-transparent bg-clip-text">
                Reliable and Secure Features
              </span>
            </h2>
          </div>

          <div className="flex flex-wrap mt-10 lg:mt-20">
            {chainsphere1.map((chainsphere1, index) => (
              <div key={index} className="w-full sm:w-1/2 lg:w-1/3">
                <div className="flex">
                  <div className="flex mx-6 h-20 w-20 p-2 bg-neutral-900 text-orange-700 justify-center items-center rounded-full">
                    {chainsphere1.icon}
                  </div>
                  <div>
                    <h5 className="mt-1 mb-6 text-3xl">{chainsphere1.text}</h5>
                    <p className="text-3xl p-2 mb-20 text-neutral-500">
                      {chainsphere1.description}
                    </p>
                  </div>
                </div>
              </div>
            ))}
          </div>

          {/* 4 */}
          <div className="relative mt-20 border-b border-neutral-800 min-h-[800px]">
            <div className="text-center">
              <span className="bg-neutral-900 text-orange-500 rounded-full h-6 text-md font-medium px-2 py-1 uppercase">
                The Benefits of Chain Sphere
              </span>
              <h2 className="text-3xl sm:text-4xl lg:text-8xl mt-10 lg:mt-20 tracking-wide">
                Transforming Social{" "}
                <span className="bg-gradient-to-r from-orange-500 to-orange-800 text-transparent bg-clip-text">
                  Media Experience
                </span>
              </h2>
            </div>

            <div className="flex flex-wrap mt-10 lg:mt-20">
              {chainsphere2.map((chainsphere2, index) => (
                <div key={index} className="w-full sm:w-1/2 lg:w-1/3">
                  <div className="flex">
                    <div className="flex mx-6 h-20 w-20 p-2 bg-neutral-900 text-orange-700 justify-center items-center rounded-full">
                      {chainsphere2.icon}
                    </div>
                    <div>
                      <h5 className="mt-1 mb-6 text-3xl">{chainsphere2.text}</h5>
                      <p className="text-3xl p-2 mb-20 text-neutral-500">
                        {chainsphere2.description}
                      </p>
                    </div>
                  </div>
                </div>
              ))}
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};

export default FeatureSection;
