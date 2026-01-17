module.exports = ({ env }) => ({
    email: {
        config: {
            provider: 'sendgrid',
            providerOptions: {
                apiKey: env('SENDGRID_API_KEY'),
            },
            settings: {
                defaultFrom: env('SMTP_FROM_EMAIL'),
                defaultReplyTo: env('SMTP_REPLY_TO_EMAIL'),
            },
        },
    },
});
