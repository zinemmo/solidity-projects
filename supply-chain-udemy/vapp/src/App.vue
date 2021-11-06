<template>
  <div v-if="isDrizzleInitialized" id="app">
    <div class="section">
      <h1>Item Manager DApp</h1>
    </div>
    <div class="section">
      <h2>Show the Accounts</h2>
      <drizzle-account units="Ether" :precision="2" />
    </div>

    <div class="section">
      <h2>Add Item</h2>
      <ItemManager />
    </div>

    <div class="section">
      <h2>Check Item Status</h2>
    </div>

    <div class="section">
      <h2>Complex Storage</h2>
    </div>
  </div>

  <div v-else>Loading...</div>
</template>

<script>
import ItemManager from './ItemManager';
import { mapGetters } from 'vuex';

export default {
  name: 'app',
  components: {
    ItemManager,
  },
  computed: mapGetters('drizzle', ['isDrizzleInitialized']),
};
</script>

<style>
#app {
  font-family: 'Avenir', Helvetica, Arial, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  text-align: center;
  color: #2c3e50;
  margin-top: 60px;
}
</style>
