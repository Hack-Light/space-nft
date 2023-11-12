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
  const [spaceBalance, setSpaceBalance] = useState<number>(0);
  const [planetBalance, setPlanetBalance] = useState<number>(0);
  const [jupiterBalance, setJupiterBalance] = useState<number>(0);
  const [shootingStarBalance, setShootingStarBalance] = useState<number>(0);

  const [isLoading, setIsLoading] = useState(true);
  const [isMinting, setIsMinting] = useState(false);
  const [isComposing, setIsComposing] = useState(false);

  // tokenids
  const [pTokenId, setPTokenId] = useState(BigInt(0));
  const [jTokenId, setJTokenId] = useState(BigInt(0));
  const [sTokenId, setSTokenId] = useState(BigInt(0));

  // user account
  const { address: connectedAccount, isConnected } = useAccount();

  // contracts
  const { data: spaceContract, isLoading: isLoadingSpaceContract } = useDeployedContractInfo("Space");
  const { data: planetContract, isLoading: isLoadingPlanetContract } = useDeployedContractInfo("Planet");
  const { data: jupiterContract, isLoading: isLoadingJupiterContract } = useDeployedContractInfo("Jupiter");
  const { data: shootingStarContract, isLoading: isLoadingShootingStarContract } =
    useDeployedContractInfo("ShootingStar");

  const publicClient = usePublicClient();
  const { data: signer, isLoading: isLoadingSigner } = useWalletClient();

  const handleMint = async (body: BodiesProps) => {
    if (isLoadingPlanetContract || isLoadingJupiterContract || isLoadingSigner) return;

    if (!planetContract?.address) return;
    if (!jupiterContract?.address) return;
    if (!shootingStarContract?.address) return;

    if (isMinting) {
      notification.info(`Currently minting ${body.name}`);
      return;
    }

    setIsMinting(true);
    setIsLoading(true);

    const notificationId = notification.loading(`Minting One(1) ${body.name}`);

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
        case "Jupiter":
          hash = await signer?.writeContract({
            address: jupiterContract.address,
            abi: jupiterContract.abi,
            functionName: "mint",
            value: parseEther("0.01"),
          });
          break;
        case "ShootingStar":
          hash = await signer?.writeContract({
            address: shootingStarContract.address,
            abi: shootingStarContract.abi,
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
      notification.error(`Error occured while trying to mint ${body.name}`);
      console.log(error);
    }

    notification.remove(notificationId);
    setIsMinting(false);
    setIsLoading(false);
  };

  const handleSet = async (body: BodiesProps) => {
    if (isComposing || !isConnected || isLoadingSigner || !connectedAccount || isLoadingSpaceContract) return;

    if (spaceBalance < 1) {
      notification.error(`Try minting a space nft first`);
      return;
    }

    if (!spaceContract?.address) {
      notification.error(`Space Contract not loaded`);
      return;
    }

    setIsComposing(true);
    setIsLoading(true);

    if (!planetContract?.address) return;
    if (!jupiterContract?.address) return;
    if (!shootingStarContract?.address) return;

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
              pTokenId,
              encodeAbiParameters(parseAbiParameters("uint256"), [BigInt(pTokenId) || BigInt(0)]),
            ],
            gas: BigInt(500000),
          });
          break;
        case "Jupiter":
          if (isLoadingJupiterContract) return;

          hash = await signer?.writeContract({
            address: jupiterContract.address,
            abi: jupiterContract.abi,
            functionName: "safeTransferFrom",
            args: [
              connectedAccount,
              spaceContract?.address,
              jTokenId,
              encodeAbiParameters(parseAbiParameters("uint256"), [BigInt(jTokenId) || BigInt(0)]),
            ],
            gas: BigInt(500000),
          });
          break;
        case "ShootingStar":
          if (isLoadingShootingStarContract) return;

          hash = await signer?.writeContract({
            address: shootingStarContract.address,
            abi: shootingStarContract.abi,
            functionName: "safeTransferFrom",
            args: [
              connectedAccount,
              spaceContract?.address,
              sTokenId,
              encodeAbiParameters(parseAbiParameters("uint256"), [BigInt(sTokenId) || BigInt(0)]),
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
      notification.error(`Error occured while trying to compose ${body.name}`);
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
      case "jupiter":
        return jupiterBalance;
      case "shooting-star":
        return shootingStarBalance;
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
      if (!jupiterContract?.address) return;
      if (!shootingStarContract?.address) return;
      if (!spaceContract?.address) return;
      if (!connectedAccount) return;

      // space balance
      let balance = await publicClient.readContract({
        address: spaceContract.address,
        abi: spaceContract.abi,
        functionName: "balanceOf",
        args: [connectedAccount],
      });

      if (balance < BigInt(1)) balance = BigInt(0);

      setSpaceBalance(Number(balance.toString()));

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

        console.log("planetid", planetid);

        setPTokenId(planetid);
      }

      // balance and tokenid for jupiter
      const jBalance = await publicClient.readContract({
        address: jupiterContract.address,
        abi: jupiterContract.abi,
        functionName: "balanceOf",
        args: [connectedAccount],
      });

      setJupiterBalance(Number(jBalance.toString()));

      if (Number(jBalance.toString()) > 0) {
        const jupiter = getContract({
          address: jupiterContract.address,
          abi: jupiterContract.abi,
          publicClient,
        });

        const jupiterid = await jupiter.read.tokenOfOwnerByIndex([connectedAccount, BigInt(Number(jBalance) - 1)]);

        setJTokenId(jupiterid);
      }

      // balance and tokenid for shooting star
      const sBalance = await publicClient.readContract({
        address: shootingStarContract.address,
        abi: shootingStarContract.abi,
        functionName: "balanceOf",
        args: [connectedAccount],
      });

      setShootingStarBalance(Number(sBalance.toString()));

      if (Number(sBalance.toString()) > 0) {
        const jupiter = getContract({
          address: shootingStarContract.address,
          abi: shootingStarContract.abi,
          publicClient,
        });

        const shootingid = await jupiter.read.tokenOfOwnerByIndex([connectedAccount, BigInt(Number(sBalance) - 1)]);

        setSTokenId(shootingid);
      }

      setIsLoading(false);
    })();
  }, [
    isMinting,
    isComposing,
    isConnected,
    connectedAccount,
    isLoadingSpaceContract,
    isLoadingPlanetContract,
    isLoadingShootingStarContract,
  ]);

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

                    if (bodyBalance >= 1) {
                      handleSet(body);
                    } else {
                      handleMint(body);
                    }
                  }}
                  className="btn btn-small"
                >
                  {getBodyBalance(body.id) >= 1 ? "Set" : "Mint"}
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
