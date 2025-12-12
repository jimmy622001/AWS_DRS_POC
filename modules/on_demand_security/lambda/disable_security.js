/**
 * Lambda function to disable security services when returning to normal operations
 */
const AWS = require('aws-sdk');

exports.handler = async (event) => {
    console.log('Disable Security Lambda triggered');
    
    try {
        // Get environment variables
        const guarddutyId = process.env.GUARDDUTY_ID;
        const loadBalancerArn = process.env.LOAD_BALANCER_ARN;
        
        if (!guarddutyId || !loadBalancerArn) {
            throw new Error('Missing required environment variables');
        }

        // Initialize AWS clients
        const wafv2 = new AWS.WAFV2();
        const guardduty = new AWS.GuardDuty();
        
        // 1. Disable GuardDuty
        console.log(`Disabling GuardDuty detector: ${guarddutyId}`);
        // Disable each feature individually first
        try {
            console.log('Disabling EKS_RUNTIME_MONITORING feature');
            await guardduty.updateMemberDetectors({
                DetectorId: guarddutyId,
                AccountIds: ['CURRENT_ACCOUNT'], // This will be replaced by actual account ID in production
                Features: [{
                    Name: 'EKS_RUNTIME_MONITORING',
                    Status: 'DISABLED'
                }]
            }).promise();
        } catch (featureError) {
            console.warn('Error disabling EKS_RUNTIME_MONITORING:', featureError);
            // Continue with other features even if one fails
        }
        
        try {
            console.log('Disabling RDS_LOGIN_EVENTS feature');
            await guardduty.updateMemberDetectors({
                DetectorId: guarddutyId,
                AccountIds: ['CURRENT_ACCOUNT'], // This will be replaced by actual account ID in production
                Features: [{
                    Name: 'RDS_LOGIN_EVENTS',
                    Status: 'DISABLED'
                }]
            }).promise();
        } catch (featureError) {
            console.warn('Error disabling RDS_LOGIN_EVENTS:', featureError);
        }
        
        try {
            console.log('Disabling ECS_RUNTIME_MONITORING feature');
            await guardduty.updateMemberDetectors({
                DetectorId: guarddutyId,
                AccountIds: ['CURRENT_ACCOUNT'], // This will be replaced by actual account ID in production
                Features: [{
                    Name: 'ECS_RUNTIME_MONITORING',
                    Status: 'DISABLED'
                }]
            }).promise();
        } catch (featureError) {
            console.warn('Error disabling ECS_RUNTIME_MONITORING:', featureError);
        }
        
        // Finally disable the GuardDuty detector
        await guardduty.updateDetector({
            DetectorId: guarddutyId,
            Enable: false
        }).promise();
        
        // 2. Disassociate WAF WebACL from the load balancer
        console.log(`Disassociating WAF WebACL from load balancer ${loadBalancerArn}`);
        await wafv2.disassociateWebACL({
            ResourceArn: loadBalancerArn
        }).promise();
        
        console.log('Successfully deactivated all security services');
        return {
            statusCode: 200,
            body: JSON.stringify({
                message: 'Security services deactivated successfully',
                guarddutyDisabled: true,
                wafDisassociated: true
            })
        };
    } catch (error) {
        console.error('Error deactivating security services:', error);
        throw error;
    }
};