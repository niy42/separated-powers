import { ConnectedWallet } from '@privy-io/react-auth';

export type Role = "Admin" | "Member" | "Whale" | "Senior" | "Guest";

export type Status = "idle" | "loading" | "error" | "success"

export type useActionsProps = { wallet: ConnectedWallet, disabled: boolean }