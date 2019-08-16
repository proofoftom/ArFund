<template>
  <!-- eslint-disable -->
  <v-app>
    <v-app-bar app>
      <v-layout align-center justify-space-between>
        <v-toolbar-title class="headline text-uppercase">
          <span>Ar</span>
          <span class="font-weight-light">Fund</span>
        </v-toolbar-title>
        <v-btn text href="https://github.com/proofoftom/arweave-crowdfund" target="_blank">
          <span class="mr-2">Latest Release</span>
          <v-icon>fas fa-external-link-alt</v-icon>
        </v-btn>
      </v-layout>
    </v-app-bar>

    <v-content>
      <router-view />
    </v-content>
  </v-app>
</template>

<script>
export default {
  name: "App"
};
</script>
