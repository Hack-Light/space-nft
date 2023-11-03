/* eslint-disable react-hooks/exhaustive-deps */

/* eslint-disable @next/next/no-img-element */

/* eslint-disable jsx-a11y/alt-text */
import { useEffect, useState } from "react";
import { Spinner } from "../assets/Spinner";
import SVG from "react-inlinesvg";
import { getContract } from "viem";
import { useAccount, usePublicClient } from "wagmi";
import { useDeployedContractInfo } from "~~/hooks/scaffold-eth";
import { definitions, grey_stars, shooting2, shooting3, sun, white_stars, yellow_stars } from "~~/public/svg";

interface Metadata {
  name: string;
  image: string | null;
}

const Space = ({ balance }: { balance: number }) => {
  const [metadata, setMetadata] = useState<Metadata | null>(null); // Use null as initial value
  const [isLoading, setIsLoading] = useState(true);
  const [userBalance, setUserBalance] = useState(balance);

  console.log("space balance", userBalance);

  const { address: connectedAccount, isConnected } = useAccount();
  const publicClient = usePublicClient();
  const { data: spaceContract, isLoading: isLoadingSpaceContract } = useDeployedContractInfo("Space");

  const getDetails = async () => {
    console.log("getting details", isLoadingSpaceContract, isLoadingSpaceContract, isConnected);
    if (isLoadingSpaceContract || !isConnected) return;
    if (!spaceContract?.address) return;
    console.log("getting details 1");

    const space = getContract({
      address: spaceContract.address,
      abi: spaceContract.abi,
      publicClient,
    });

    try {
      setIsLoading(true);
      setUserBalance(balance);

      if (!connectedAccount) return;
      const id = await space.read.tokenOfOwnerByIndex([connectedAccount, BigInt(userBalance - 1)]);

      const tokenURI = await space.read.renderTokenById([BigInt(id)]);

      console.log("tokenUrI", tokenURI);

      // const metadata1 = await (await fetch(tokenURI)).json();
      // console.log("Image", metadata1);
      // const img = await (await fetch(metadata.image)).text();

      const metadata = {
        name: `Space #${id}`,
        image: "",
      };

      const fullImage = placeSVGVariables(tokenURI);

      metadata.image = `${fullImage}`;

      // console.log(fullImage);

      setMetadata(metadata);
    } catch (error) {
      console.error(error);
    } finally {
      setIsLoading(false);
    }
  };

  const placeSVGVariables = (image: string) => {
    return image
      .replace("#definition", definitions)
      .replace("#greyStars", grey_stars)
      .replace("#yellowStars", yellow_stars)
      .replace("#whiteStars", white_stars)
      .replace("#sun", sun)
      .replace("#shooting1", shooting3)
      .replace("#shooting2", shooting2);
  };

  useEffect(() => {
    getDetails();
  }, [isLoadingSpaceContract]);

  return (
    <div className="container">
      <div className="row">
        <div className="col-md-12">
          <div className="profile-card-2">
            {metadata ? (
              <SVG src={metadata.image || ""} />
            ) : isLoading ? (
              <Spinner />
            ) : (
              <p style={{ margin: "0 auto" }}>No Spaces yet</p>
            )}{" "}
            {/* Return null when metadata is not available */}
          </div>
        </div>
      </div>
    </div>
  );
};

export default Space;
