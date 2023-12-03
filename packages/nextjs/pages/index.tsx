/* eslint-disable react-hooks/exhaustive-deps */

/* eslint-disable @next/next/no-img-element */

/* eslint-disable jsx-a11y/alt-text */
import Link from "next/link";
import type { NextPage } from "next";
import { MetaHeader } from "~~/components/MetaHeader";

const Home: NextPage = () => {
  return (
    <>
      <MetaHeader />
      <section id="c-container">
        <div id="c-row">
          <div id="c-content">
            <h1 id="c-h1">Explore the limitless canvas of space</h1>
            <h4 id="c-h4">The beauty of space is boundless</h4>
            <p id="c-p">
              Lorem ipsum dolor sit amet consectetur adipisicing elit. Ea inventore nam quis commodi temporibus illum
              placeat tempora, ipsa veritatis ratione soluta cupiditate sit id pariatur doloremque consectetur dolores
              vel cumque.
            </p>
          </div>
          <Link style={{ color: "white" }} href="/mint" id="c-mint-btn">
            Mint Space 0.2 ETH
          </Link>

          {/* </a> */}
        </div>
        <div></div>
      </section>
    </>
  );
};

export default Home;
