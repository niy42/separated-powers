import { useState, useEffect } from 'react';
import { getRole, getBalance } from '@/blockChainUtils/blockchainUtils2';

import MemberActions from '../shared/MemberActions';
import WhaleActions from '../shared/WhaleActions';
import SeniorActions from '../shared/SeniorActions';
import AdminActions from '../shared/AdminActions';

interface RoleBasedUIProps {
    address: string;
}

const RoleBasedUI: React.FC<RoleBasedUIProps> = ({ address }) => {
    const [role, setRole] = useState<string>('');
    const [balance, setBalance] = useState<number>(0);

    useEffect(() => {
        const fetchRoleAndBalance = async () => {
            const userRole = await getRole(address);
            const userBalance = await getBalance(address);
            setRole(userRole);
            setBalance(userBalance);
        };

        if (address) {
            fetchRoleAndBalance();
        }
    }, [address]);

    return (
        <div>
            <h2>Your Role: {role}</h2>
            <p>Your Balance: {balance} agCoins</p>
            {role === 'Member' && <MemberActions />}
            {/* address={address} */}
            {role === 'Whale' && <WhaleActions />}
            {/* seniorAddress={address}  */}
            {role === 'Senior' && <SeniorActions />}
            {/* adminAddress={address} */}
            {role === 'Admin' && <AdminActions  />}
        </div>
    );
};

export default RoleBasedUI;
