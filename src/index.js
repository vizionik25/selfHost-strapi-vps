'use strict';

module.exports = {
    /**
     * An asynchronous register function that runs before
     * your application is initialized.
     *
     * @param {Object} params
     * @param {Strapi} params.strapi
     */
    register({ strapi }) { },

    /**
     * An asynchronous bootstrap function that runs before
     * your application gets started.
     *
     * @param {Object} params
     * @param {Strapi} params.strapi
     */
    bootstrap({ strapi }) { },
};
