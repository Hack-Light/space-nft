// GlobalStyles.tsx
import { useEffect } from "react";
import { useRouter } from "next/router";
import { createGlobalStyle } from "styled-components";

export const GlobalStyles = createGlobalStyle`
  body {
    background: url('/home.jpg'); /* Default background image */
  }

  body.home {
    background: url('/home.jpg');
  }

  body.bodies {
    background: #342454;
  }

  body.mint {
    background: #342454;
  }

  /* Add more styles for other pages as needed */
`;

export const DynamicStyles = () => {
  const router = useRouter();

  useEffect(() => {
    // Extract the first segment of the pathname to determine the current page
    const currentPage = router.pathname.split("/")[1];

    // Apply the corresponding class to the body
    document.body.className = currentPage || "default";
  }, [router.pathname]);

  return null;
};
