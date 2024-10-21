import { useState, useEffect } from 'react';
import { getRole, getBalance } from '../../utils/blockchainUtils2';
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
            {role === 'Whale' && <WhaleActions address={address} />}
            {role === 'Senior' && <SeniorActions seniorAddress={address} />}
            {role === 'Admin' && <AdminActions adminAddress={address} />}
        </div>
    );
};

export default RoleBasedUI;
