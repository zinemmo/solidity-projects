<template>
  <div v-if="isDrizzleInitialized">
    <drizzle-contract-form contractName="ItemManager" method="createItem" />
    <button @click="handleClick">
      Get Items
    </button>
    <!-- <drizzle-contract
      contractName="ItemManager"
      method="symbol"
      label="Symbol"
    />
    <drizzle-contract
      contractName="ItemManager"
      method="balanceOf"
      label="Your Balance"
      :methodArgs="accounts"
    />

    <drizzle-contract-form
      contractName="ItemManager"
      method="transfer"
      :placeholders="placeholders"
    /> -->
  </div>

  <div v-else>Loading...</div>
</template>

<script>
import { mapGetters } from 'vuex';

export default {
  name: 'ItemManager',
  computed: {
    ...mapGetters('accounts', ['activeAccount', 'activeBalance']),
    ...mapGetters('drizzle', ['isDrizzleInitialized']),

    accounts() {
      return [this.activeAccount];
    },

    placeholders() {
      return ['To Address', 'Amount to Send'];
    },
  },
  methods: {
    handleClick: async () => {
      // eslint-disable-next-line no-console
      console.log('Teste');
    },
  },
};
</script>

<style></style>
