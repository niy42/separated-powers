'use client';

import { PrivyClientConfig, PrivyProvider } from '@privy-io/react-auth';


const privyConfig: PrivyClientConfig = {
  loginMethods: ['wallet'],
  appearance: {
      theme: 'light',
      accentColor: '#676FFF',
      logo: 'your-logo-url'
  },
   // Create embedded wallets for users who don't have a wallet
  embeddedWallets: {
    createOnLogin: 'users-without-wallets',
  },
};

export function Providers({children}: {children: React.ReactNode}) {
  return (  
      <PrivyProvider
        appId={process.env.NEXT_PUBLIC_PRIVY_APP_ID as string}
        config={privyConfig}
        >
         {children}
      </PrivyProvider> 
  );
}