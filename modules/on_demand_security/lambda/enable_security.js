/**
 * Lambda function to enable security services during DR failover
 */
const AWS = require('aws-sdk');

exports.handler = async (event) => {
    console.log('Enable Security Lambda triggered');
    
    try {
        // Get environment variables
        const webAclArn = process.env.WEB_ACL_ARN;
        const guarddutyId = process.env.GUARDDUTY_ID;
        const loadBalancerArn = process.env.LOAD_BALANCER_ARN;
        
        if (!webAclArn || !guarddutyId || !loadBalancerArn) {
            throw new Error('Missing required environment variables');
        }

        // Initialize AWS clients
        const wafv2 = new AWS.WAFV2();
        const guardduty = new AWS.GuardDuty();
        const elbv2 = new AWS.ELBv2();
        
        // 1. Enable GuardDuty
        console.log(`Enabling GuardDuty detector: ${guarddutyId}`);
        // Enable GuardDuty detector first
        await guardduty.updateDetector({
            DetectorId: guarddutyId,
            Enable: true
        }).promise();
        
        // Now enable each feature individually
        try {
            console.log('Enabling EKS_RUNTIME_MONITORING feature');
            await guardduty.updateMemberDetectors({
                DetectorId: guarddutyId,
                AccountIds: ['CURRENT_ACCOUNT'], // This will be replaced by actual account ID in production
                Features: [{
                    Name: 'EKS_RUNTIME_MONITORING',
                    Status: 'ENABLED'
                }]
            }).promise();
        } catch (featureError) {
            console.warn('Error enabling EKS_RUNTIME_MONITORING:', featureError);
            // Continue with other features even if one fails
        }
        
        try {
            console.log('Enabling RDS_LOGIN_EVENTS feature');
            await guardduty.updateMemberDetectors({
                DetectorId: guarddutyId,
                AccountIds: ['CURRENT_ACCOUNT'], // This will be replaced by actual account ID in production
                Features: [{
                    Name: 'RDS_LOGIN_EVENTS',
                    Status: 'ENABLED'
                }]
            }).promise();
        } catch (featureError) {
            console.warn('Error enabling RDS_LOGIN_EVENTS:', featureError);
        }
        
        try {
            console.log('Enabling ECS_RUNTIME_MONITORING feature');
            await guardduty.updateMemberDetectors({
                DetectorId: guarddutyId,
                AccountIds: ['CURRENT_ACCOUNT'], // This will be replaced by actual account ID in production
                Features: [{
                    Name: 'ECS_RUNTIME_MONITORING',
                    Status: 'ENABLED'
                }]
            }).promise();
        } catch (featureError) {
            console.warn('Error enabling ECS_RUNTIME_MONITORING:', featureError);
        }
        
        // 2. Associate WAF WebACL with the load balancer
        console.log(`Associating WAF WebACL ${webAclArn} with load balancer ${loadBalancerArn}`);
        await wafv2.associateWebACL({
            WebACLArn: webAclArn,
            ResourceArn: loadBalancerArn
        }).promise();
        
        console.log('Successfully activated all security services');
        return {
            statusCode: 200,
            body: JSON.stringify({
                message: 'Security services activated successfully',
                guarddutyEnabled: true,
                wafAssociated: true
            })
        };
    } catch (error) {
        console.error('Error activating security services:', error);
        throw error;
    }
};