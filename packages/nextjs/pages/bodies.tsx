/* eslint-disable react/jsx-key */

/* eslint-disable react-hooks/exhaustive-deps */

/* eslint-disable @next/next/no-img-element */

/* eslint-disable jsx-a11y/alt-text */
import { useEffect, useState } from "react";
import type { NextPage } from "next";
import { encodeAbiParameters, getContract, parseAbiParameters, parseEther } from "viem";
import { useAccount, usePublicClient, useWalletClient } from "wagmi";
import { MetaHeader } from "~~/components/MetaHeader";
import { Spinner } from "~~/components/assets/Spinner";
import { useDeployedContractInfo } from "~~/hooks/scaffold-eth";
import { notification } from "~~/utils/scaffold-eth";

interface BodiesProps {
  name: string;
  price: number;
  id: "planet" | "jupiter" | "shooting-star";
  image: string;
  style?: any;
}

const bodies: BodiesProps[] = [
  { name: "Planet", price: 0.01, id: "planet", image: "/planet.svg" },
  { name: "Jupiter", price: 0.01, id: "jupiter", image: "/jupiter.svg" },
  { name: "ShootingStar", price: 0.01, id: "shooting-star", image: "/shooting.svg", style: { objectPosition: "top" } },
];

const Home: NextPage = () => {
  // component states
  const [planetBalance, setPlanetBalance] = useState<number>(0);
  // const [balance, setBalance] = useState<number>(0);
  // const [balance, setBalance] = useState<number>(0);
  const [isLoading, setIsLoading] = useState(true);
  const [isMinting, setIsMinting] = useState(false);
  const [isComposing, setIsComposing] = useState(false);
  const [tokenIds, setTokenIds] = useState({ planet: BigInt(0), jupiter: BigInt(0), "shooting-star": BigInt(0) });

  // user account
  const { address: connectedAccount, isConnected } = useAccount();

  // contracts
  const { data: spaceContract, isLoading: isLoadingSpaceContract } = useDeployedContractInfo("Space");
  const { data: planetContract, isLoading: isLoadingPlanetContract } = useDeployedContractInfo("Planet");
  // const { data: spaceContract, isLoading: isLoadingSpaceContract } = useDeployedContractInfo("Jupiter");
  // const { data: spaceContract, isLoading: isLoadingSpaceContract } = useDeployedContractInfo("ShootingStar");

  const publicClient = usePublicClient();
  const { data: signer, isLoading: isLoadingSigner } = useWalletClient();

  const handleMint = async (body: BodiesProps) => {
    if (isLoadingPlanetContract || isLoadingSigner) return;

    if (!planetContract?.address) return;

    if (isMinting) {
      notification.info("Currently minting space");
      return;
    }

    setIsMinting(true);
    setIsLoading(true);

    const notificationId = notification.loading("Minting One(1) Space");

    let hash: `0x${string}` | undefined;

    try {
      switch (body.name) {
        case "Planet":
          hash = await signer?.writeContract({
            address: planetContract.address,
            abi: planetContract.abi,
            functionName: "mint",
            value: parseEther("0.01"),
          });
          break;

        default:
          break;
      }

      if (!hash) return;

      await publicClient.waitForTransactionReceipt({ hash });
    } catch (error) {
      notification.error(JSON.stringify(error));
    }

    notification.remove(notificationId);
    setIsMinting(false);
    setIsLoading(false);
  };

  const handleSet = async (body: BodiesProps, tokenId: bigint) => {
    if (isComposing || !isConnected || isLoadingSigner || !connectedAccount || isLoadingSpaceContract) return;

    if (!spaceContract?.address) return;

    if (!tokenId) return;

    setIsComposing(true);
    setIsLoading(true);

    if (!planetContract?.address) return;

    const notificationId = notification.loading(`Transferring ${body.name}`);

    try {
      let hash: `0x${string}` | undefined;

      switch (body.name) {
        case "Planet":
          if (isLoadingPlanetContract) return;

          hash = await signer?.writeContract({
            address: planetContract.address,
            abi: planetContract.abi,
            functionName: "safeTransferFrom",
            args: [
              connectedAccount,
              spaceContract?.address,
              tokenId,
              encodeAbiParameters(parseAbiParameters("uint256"), [BigInt(tokenId) || BigInt(0)]),
            ],
            gas: BigInt(500000),
          });
          break;

        default:
          break;
      }

      if (!hash) return;

      await publicClient.waitForTransactionReceipt({ hash });
    } catch (error) {
      console.log(error);
    }
    notification.remove(notificationId);
    setIsComposing(false);
    setIsLoading(false);
  };

  const getBodyBalance = (bodyId: string): number => {
    // Add logic to retrieve the balance for the given bodyId
    switch (bodyId) {
      case "planet":
        return planetBalance;
      // Add cases for other bodies as needed
      default:
        return 0; // Default to 0 if balance information is not available
    }
  };

  useEffect(() => {
    (async () => {
      if (!isConnected) return;

      setIsLoading(true);
      setIsMinting(false);

      if (!planetContract?.address) return;
      if (!connectedAccount) return;

      // balance and tokenid for planet
      const pBalance = await publicClient.readContract({
        address: planetContract.address,
        abi: planetContract.abi,
        functionName: "balanceOf",
        args: [connectedAccount],
      });

      setPlanetBalance(Number(pBalance.toString()));

      if (Number(pBalance.toString()) > 0) {
        const planet = getContract({
          address: planetContract.address,
          abi: planetContract.abi,
          publicClient,
        });

        const planetid = await planet.read.tokenOfOwnerByIndex([connectedAccount, BigInt(Number(pBalance) - 1)]);

        setTokenIds({ ...tokenIds, planet: planetid });
      }

      setIsLoading(false);
    })();
  }, [isConnected, connectedAccount, isLoadingSpaceContract, isLoadingPlanetContract]);

  return (
    <>
      <MetaHeader />
      <div className="body">
        {bodies.map(body => (
          <a key={body.id} href="#" className="card">
            <img src={body.image} alt="balloon with an emoji face" className="card__img" style={body?.style || {}} />
            <span className="card__footer">
              <span>{body.name}</span>
              <span>{body.price} ETH</span>
              <span>
                Balance: <span>{getBodyBalance(body.id)}</span>
              </span>
            </span>
            <span className="card__action">
              {!isLoading ? (
                <div
                  onClick={() => {
                    const bodyBalance = getBodyBalance(body.id);

                    if (bodyBalance === 1) {
                      handleSet(body, tokenIds[body.id]);
                    } else {
                      handleMint(body);
                    }
                  }}
                  className="btn btn-small"
                >
                  {getBodyBalance(body.id) === 1 ? "Set" : "Mint"}
                </div>
              ) : !isConnected ? (
                <p>Connect Wallet</p>
              ) : (
                <Spinner />
              )}
            </span>
          </a>
        ))}
      </div>
    </>
  );
};

export default Home;
