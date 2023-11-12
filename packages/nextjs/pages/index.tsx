/* eslint-disable react-hooks/exhaustive-deps */

/* eslint-disable @next/next/no-img-element */

/* eslint-disable jsx-a11y/alt-text */
import { useEffect, useState } from "react";
import type { NextPage } from "next";
import { parseEther } from "viem";
import { useAccount, usePublicClient, useWalletClient } from "wagmi";
import { MetaHeader } from "~~/components/MetaHeader";
import { Spinner } from "~~/components/assets/Spinner";
import Space from "~~/components/cards/Space";
import { useDeployedContractInfo } from "~~/hooks/scaffold-eth";
import { notification } from "~~/utils/scaffold-eth";

const Home: NextPage = () => {
  const [balance, setBalance] = useState<number>(0);
  const [isLoading, setIsLoading] = useState(true);
  const [isMinting, setIsMinting] = useState(false);
  const [mintText, setMintText] = useState("");

  const { address: connectedAccount, isConnected } = useAccount();

  const { data: spaceContract, isLoading: isLoadingSpaceContract } = useDeployedContractInfo("Space");

  const publicClient = usePublicClient();

  const { data: signer, isLoading: isLoadingSigner } = useWalletClient();

  const handleMint = async () => {
    if (isLoadingSpaceContract || isLoadingSigner) return;

    if (mintText === "") {
      notification.info("Add text to customize your space");
      return;
    }

    if (!spaceContract?.address) return;

    if (isMinting) {
      notification.info("Currently minting space");
      return;
    }

    setIsMinting(true);

    const notificationId = notification.loading("Minting One(1) Space");

    try {
      const hash = await signer?.writeContract({
        address: spaceContract.address,
        abi: spaceContract.abi,
        functionName: "mint",
        value: parseEther("0.02"),
        args: [mintText],
      });

      if (!hash) return;

      await publicClient.waitForTransactionReceipt({ hash });

      notification.success("Minted One(1) Space");
      setBalance(balance + 1);
    } catch (error) {
      notification.error(JSON.stringify(error));
    }

    notification.remove(notificationId);
    setIsMinting(false);
  };

  useEffect(() => {
    (async () => {
      if (!isConnected || isLoadingSpaceContract) return;

      setIsLoading(true);

      if (!spaceContract?.address) return;
      if (!connectedAccount) return;

      let balance = await publicClient.readContract({
        address: spaceContract.address,
        abi: spaceContract.abi,
        functionName: "balanceOf",
        args: [connectedAccount],
      });

      if (balance < BigInt(1)) balance = BigInt(0);

      setBalance(Number(balance.toString()));
      setIsLoading(false);
    })();
  }, [isLoadingSpaceContract, isConnected, connectedAccount, isMinting]);

  return (
    <>
      <MetaHeader />
      <div style={{ display: "flex" }}>
        {!isLoading ? (
          <Space balance={balance} />
        ) : !isConnected ? (
          <p style={{ margin: "0 auto" }}>Connect Wallet</p>
        ) : (
          <Spinner />
        )}
        <header>
          <div className="container text-center">
            <div className="logo">
              <div>
                <label htmlFor="first_name" className="block mb-2 text-sm font-medium text-gray-900 dark:text-white">
                  Prefered Text
                </label>
                <input
                  type="text"
                  id="first_name"
                  className="bg-gray-50 border border-gray-300 text-gray-900 text-sm rounded-lg focus:ring-blue-500 focus:border-blue-500 block p-2.5 dark:bg-gray-700 dark:border-gray-600 dark:placeholder-gray-400 dark:text-white dark:focus:ring-blue-500 dark:focus:border-blue-500"
                  placeholder="hacklight.eth"
                  style={{ margin: "20px auto", width: "300px" }}
                  required
                  minLength={13}
                  onChange={e => {
                    setMintText(e.target.value);
                  }}
                />
              </div>
            </div>

            <p onClick={handleMint} className="btn btn-primary btn-large">
              {isMinting ? <Spinner /> : "Mint Space"}
            </p>
          </div>
        </header>
      </div>
    </>
  );
};

export default Home;
