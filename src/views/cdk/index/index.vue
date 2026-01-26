<template>
  <div class="ele-body">
    <cdk-list ref="tableOrganization" @rowEdit="openEdit" />
    <cdk-gen v-if="showEdit && showType === 'edit'" @close="showEdit = false" :data="current" :visible="showEdit"
      @done="reload" />
  </div>
</template>

<script>
import { mapGetters } from "vuex";
import CdkGen from "./cdk-gen";
import CdkList from "./components/cdk-list";

export default {
  name: "cdk",
  components: { CdkList, CdkGen },
  computed: {
    ...mapGetters(["permission"]),
  },
  watch: {},
  data() {
    return {
      // 表格搜索条件
      where: {
      },
      // 表格选中数据
      selection: [],
      // 当前编辑数据
      current: null,
      // 是否显示编辑弹窗
      showType: "edit",
      showEdit: false,
      // 栏目列表
      cateList: [],
    };
  },
  mounted() { },
  methods: {
    /* 刷新表格 */
    reload() {
      this.showEdit = false;
      this.$refs.tableOrganization.reload({ where: this.where });
    },
    /* 显示编辑 */
    openEdit(data) {
      const { row, type } = data;
      this.current = row;
      this.showType = type;
      this.showEdit = true;
    },
  },
};
</script>

<style scoped>
.ele-form-search>>>.ele-fluid .el-range-input {
  width: 100%;
}
</style>
