import Image1 from "../assets/Rectangle 41.png";
import {useNavigate} from 'react-router-dom';
import { useSelector } from "react-redux";


export default function Links() {
  const auth = useSelector((state) => state.auth);
  console.log('auth', auth);

    const navigate = useNavigate();


    return (
        <div className="links">
    <div className="links__inner">
    <div className="links__inner__profile-group">
      <img
        className="links__inner__profile-group__img"
        src={!!auth?.userInfo?.profilePic ? `https://amethyst-abundant-squid-138.mypinata.cloud/ipfs/${auth?.userInfo?.profilePic}` : Image1}

        
        alt=""
      />
      <div className="links__inner__profile-group__name">
        <div>{auth?.userInfo?.name}</div>
        <div>@{auth?.userInfo?.username}</div>
      </div>
    </div>

    <div
      className="links__inner__trending"
      onClick={() => navigate("/feed/trending")}
    >
      <svg
        fill="#fff"
        viewBox="0 0 64 64"
        version="1.1"
        xmlns="http://www.w3.org/2000/svg"
        xmlnsXlink="http://www.w3.org/1999/xlink"
        xmlSpace="preserve"
        xmlnsSerif="http://www.serif.com/"
        style={{
          fillRule: "evenodd",
          clipRule: "evenodd",
          strokeLinejoin: "round",
          strokeMiterlimit: "2",
        }}
        stroke="#fff"
      >
        <g id="SVGRepo_bgCarrier" stroke-width="0"></g>
        <g
          id="SVGRepo_tracerCarrier"
          stroke-linecap="round"
          stroke-linejoin="round"
        ></g>
        <g id="SVGRepo_iconCarrier">
          {" "}
          <rect
            id="Icons"
            x="-704"
            y="-128"
            width="1280"
            height="800"
            style={{ fill: "none" }}
          ></rect>{" "}
          <g id="Icons1" serifId="Icons">
            {" "}
            <g id="Strike"> </g> <g id="H1"> </g> <g id="H2"> </g>{" "}
            <g id="H3"> </g> <g id="list-ul"> </g>{" "}
            <g id="hamburger-1"> </g> <g id="hamburger-2"> </g>{" "}
            <g id="list-ol"> </g> <g id="list-task"> </g>{" "}
            <g id="trash"> </g> <g id="vertical-menu"> </g>{" "}
            <g id="horizontal-menu"> </g> <g id="sidebar-2"> </g>{" "}
            <g id="Pen"> </g>{" "}
            <g id="Pen1" serifId="Pen">
              {" "}
            </g>{" "}
            <g id="clock"> </g> <g id="external-link"> </g>{" "}
            <g id="hr"> </g> <g id="info"> </g> <g id="warning"> </g>{" "}
            <g id="plus-circle"> </g> <g id="minus-circle"> </g>{" "}
            <g id="vue"> </g> <g id="cog"> </g> <g id="logo"> </g>{" "}
            <path
              id="hashtag"
              d="M34.06,42.597l-7.391,0l-2.508,13.529l-5.544,0l2.508,-13.529l-7.623,0l0,-5.214l8.613,0l1.914,-10.328l-8.019,0l0,-5.247l9.009,0l2.574,-13.727l5.51,0l-2.573,13.727l7.424,0l2.574,-13.727l5.511,0l-2.574,13.727l6.864,0l0,5.247l-7.854,0l-1.914,10.328l7.293,0l0,5.214l-8.283,0l-2.508,13.529l-5.51,0l2.507,-13.529Zm-6.401,-5.214l7.391,0l1.914,-10.328l-7.391,0l-1.914,10.328Z"
              style={{ fillRule: "nonzero" }}
            ></path>{" "}
            <g id="radio-check"> </g> <g id="eye-slash"> </g>{" "}
            <g id="eye"> </g> <g id="toggle-off"> </g>{" "}
            <g id="shredder"> </g>{" "}
            <g
              id="spinner--loading--dots-"
              serifId="spinner [loading, dots]"
            >
              {" "}
            </g>{" "}
            <g id="react"> </g> <g id="check-selected"> </g>{" "}
            <g id="turn-off"> </g> <g id="code-block"> </g>{" "}
            <g id="user"> </g> <g id="coffee-bean"> </g>{" "}
            <g id="coffee-beans">
              {" "}
              <g id="coffee-bean1" serifId="coffee-bean">
                {" "}
              </g>{" "}
            </g>{" "}
            <g id="coffee-bean-filled"> </g>{" "}
            <g id="coffee-beans-filled">
              {" "}
              <g id="coffee-bean2" serifId="coffee-bean">
                {" "}
              </g>{" "}
            </g>{" "}
            <g id="clipboard"> </g> <g id="clipboard-paste"> </g>{" "}
            <g id="clipboard-copy"> </g> <g id="Layer1"> </g>{" "}
          </g>{" "}
        </g>
      </svg>
      See what's trending
    </div>
    <div className="links__inner__divider"></div>
    <div className="links__inner__links-group">
      <a href="">Privacy</a>
      <div>·</div>
      <a href="">Terms</a>
      <div>·</div>
      <a href="">About</a>
    </div>

    </div>
    {/* <div className="links__currencies">
    <div className="links__currencies__card">
              <div className="links__currencies__card__icon">
                <svg xmlns="http://www.w3.org/2000/svg" width="32" height="32">
                  <g fill="none" fill-rule="evenodd">
                    <circle cx="16" cy="16" r="16" fill="#627EEA" />
                    <g fill="#FFF" fill-rule="nonzero">
                      <path
                        fill-opacity=".602"
                        d="M16.498 4v8.87l7.497 3.35z"
                      />
                      <path d="M16.498 4L9 16.22l7.498-3.35z" />
                      <path
                        fill-opacity=".602"
                        d="M16.498 21.968v6.027L24 17.616z"
                      />
                      <path d="M16.498 27.995v-6.028L9 17.616z" />
                      <path
                        fill-opacity=".2"
                        d="M16.498 20.573l7.497-4.353-7.497-3.348z"
                      />
                      <path
                        fill-opacity=".602"
                        d="M9 16.22l7.498 4.353v-7.701z"
                      />
                    </g>
                  </g>
                </svg>
              </div>
              <div className="links__currencies__card__content">
                <div className="links__currencies__card__content__title">
                  Ethereum
                </div>
                <div className="links__currencies__card__content__subtitle">
                  Price: <span>$40,000</span>{" "}
                  📈
                </div>
              </div>
            </div>

            <div className="links__currencies__card">
              <div className="links__currencies__card__icon">
              <svg xmlns="http://www.w3.org/2000/svg" width="32" height="32"><g fill="none" fill-rule="evenodd"><circle cx="16" cy="16" r="16" fill="#F7931A"/><path fill="#FFF" fill-rule="nonzero" d="M23.189 14.02c.314-2.096-1.283-3.223-3.465-3.975l.708-2.84-1.728-.43-.69 2.765c-.454-.114-.92-.22-1.385-.326l.695-2.783L15.596 6l-.708 2.839c-.376-.086-.746-.17-1.104-.26l.002-.009-2.384-.595-.46 1.846s1.283.294 1.256.312c.7.175.826.638.805 1.006l-.806 3.235c.048.012.11.03.18.057l-.183-.045-1.13 4.532c-.086.212-.303.531-.793.41.018.025-1.256-.313-1.256-.313l-.858 1.978 2.25.561c.418.105.828.215 1.231.318l-.715 2.872 1.727.43.708-2.84c.472.127.93.245 1.378.357l-.706 2.828 1.728.43.715-2.866c2.948.558 5.164.333 6.097-2.333.752-2.146-.037-3.385-1.588-4.192 1.13-.26 1.98-1.003 2.207-2.538zm-3.95 5.538c-.533 2.147-4.148.986-5.32.695l.95-3.805c1.172.293 4.929.872 4.37 3.11zm.535-5.569c-.487 1.953-3.495.96-4.47.717l.86-3.45c.975.243 4.118.696 3.61 2.733z"/></g></svg>
              </div>
              <div className="links__currencies__card__content">
                <div className="links__currencies__card__content__title">
                  Bitcoin
                </div>
                <div className="links__currencies__card__content__subtitle">
                  Price: <span>$60,000</span>{" "}
                  📈
                </div>
              </div>
            </div>
            <div className="links__currencies__card">
              <div className="links__currencies__card__icon">
              <svg height="32" width="32" xmlns="http://www.w3.org/2000/svg"><g fill="none" fill-rule="evenodd"><circle cx="16" cy="16" fill="#26a17b" r="16"/><path d="m17.922 17.383v-.002c-.11.008-.677.042-1.942.042-1.01 0-1.721-.03-1.971-.042v.003c-3.888-.171-6.79-.848-6.79-1.658 0-.809 2.902-1.486 6.79-1.66v2.644c.254.018.982.061 1.988.061 1.207 0 1.812-.05 1.925-.06v-2.643c3.88.173 6.775.85 6.775 1.658 0 .81-2.895 1.485-6.775 1.657m0-3.59v-2.366h5.414v-3.608h-14.741v3.608h5.414v2.365c-4.4.202-7.709 1.074-7.709 2.118s3.309 1.915 7.709 2.118v7.582h3.913v-7.584c4.393-.202 7.694-1.073 7.694-2.116s-3.301-1.914-7.694-2.117" fill="#fff"/></g></svg>
              </div>
              <div className="links__currencies__card__content">
                <div className="links__currencies__card__content__title">
                  Tether
                </div>
                <div className="links__currencies__card__content__subtitle">
                  Price: <span>$20.04</span>{" "}
                  📉
                </div>
              </div>
            </div>
    </div> */}
  </div>
    )

}