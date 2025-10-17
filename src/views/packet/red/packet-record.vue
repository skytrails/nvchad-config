<!-- 文章编辑弹窗 -->
<template>
  <el-drawer
    class="edit-table"
    :title="this.data.title"
    :visible.sync="showDrawer"
    :direction="direction"
    :size="'75%'"
    :before-close="close"
  >
    <el-card shadow="never">
      <!-- 搜索表单 -->
      <el-form
        :model="where"
        label-width="77px"
        class="ele-form-search"
        @keyup.enter.native="reload"
        @submit.native.prevent
      >
        <el-row :gutter="15">
          <el-col :lg="6" :md="12">
            <el-form-item label="用户ID:">
              <el-input
                clearable
                v-model="where.userId"
                placeholder="请输入用户ID"
              />
            </el-form-item>
          </el-col>
          <el-col :lg="6" :md="12">
            <div class="ele-form-actions">
              <el-button
                type="primary"
                icon="el-icon-search"
                class="ele-btn-icon"
                @click="reload"
                >查询
              </el-button>
              <el-button @click="reset">重置</el-button>
            </div>
          </el-col>
        </el-row>
      </el-form>
      <!-- 数据表格 -->
      <ele-pro-table
        ref="table"
        :where="where"
        :datasource="url"
        :columns="columns"
        height="calc(100vh - 315px)"
      >
        <!-- 表头工具栏 -->
        <template slot="title">{{ this.data.title }} </template>
        <template slot="creatorUserName" slot-scope="{ row }">
          <el-tag>{{ row["creatorUserName"] }}</el-tag>
        </template>
        <template slot="status" slot-scope="{ row }">
          <el-tag v-if="row.status === 0" type="info" size="mini"
            >未领取
          </el-tag>
          <el-tag v-if="row.status === 1" type="success" size="mini"
            >已领取
          </el-tag>
        </template>
        <!-- 操作列 -->
        <template slot="action" slot-scope="{ row }">
          <el-link
            v-role="['ROLE_SUPER']"
            icon="el-icon-view"
            :underline="false"
            @click="openEdit(row, 'detail')"
            >查看详情
          </el-link>
          <el-popconfirm
            v-role="['ROLE_SUPER']"
            class="ele-action"
            title="确定要删除此认证记录吗？"
            @confirm="remove(row)"
          >
            <el-link
              type="danger"
              slot="reference"
              :underline="false"
              icon="el-icon-delete"
              >删除
            </el-link>
          </el-popconfirm>
        </template>
      </ele-pro-table>
    </el-card>
  </el-drawer>
</template>

<script>
import "@riophae/vue-treeselect/dist/vue-treeselect.css";
import { mapGetters } from "vuex";
export default {
  name: "PacketEdit",
  props: {
    // 弹窗是否打开
    visible: Boolean,
    // 修改回显的数据
    data: Object,
    // 栏目数据
    cateList: Array,
  },
  data() {
    return {
      // 表格搜索条件
      url: "/packet/record/" + this.data.id,
      where: {},
      columns: [
        {
          prop: "id",
          label: "ID",
          width: 60,
          align: "center",
          showOverflowTooltip: true,
          fixed: "left",
        },
        {
          label: "红包",
          showOverflowTooltip: true,
          minWidth: 200,
          align: "center",
          slot: "title",
        },
        {
          prop: "amount",
          label: "金额",
          showOverflowTooltip: true,
          minWidth: 200,
          align: "center",
        },
        {
          prop: "status",
          label: "状态",
          showOverflowTooltip: true,
          minWidth: 200,
          align: "center",
          slot: "status",
        },
        {
          prop: "name",
          label: "领取用户Id",
          showOverflowTooltip: true,
          minWidth: 200,
          align: "center",
        },
        {
          prop: "createdAt",
          label: "创建时间",
          sortable: "custom",
          showOverflowTooltip: true,
          minWidth: 160,
          align: "center",
          formatter: (row, column, cellValue) => {
            if (!cellValue) return "";
            const date = new Date(cellValue);
            return isNaN(date) ? "Invalid Date" : date.toLocaleString();
          },
        },
        {
          prop: "updatedAt",
          label: "领取时间",
          sortable: "custom",
          showOverflowTooltip: true,
          minWidth: 160,
          align: "center",
          formatter: (row, column, cellValue) => {
            if (!cellValue) return "";
            const date = new Date(cellValue);
            return isNaN(date) ? "Invalid Date" : date.toLocaleString();
          },
        },
        // {
        //   columnKey: "action",
        //   label: "操作",
        //   width: 215,
        //   align: "center",
        //   resizable: false,
        //   slot: "action",
        //   fixed: "right",
        // },
      ],
      showDrawer: this.visible,
      direction: "rtl",
      // 表单数据
      form: Object.assign({}, this.data),
      // 提交状态
      loading: false,
      // 是否是修改
      isUpdate: false,
      // 上传目录
      updDir: "article",
    };
  },
  watch: {
    data() {
      if (this.data) {
        this.form = Object.assign({}, this.data);
        this.isUpdate = true;
      } else {
        this.form = { amount: 100, count: 50 };
        this.isUpdate = false;
      }
    },
  },
  computed: {
    ...mapGetters(["fundList"]),
  },
  mounted() {
    this.getInfo();
  },
  methods: {
    /* 重置搜索 */
    reset() {
      this.where = {};
      this.reload();
    },
    reload() {
      this.$refs.table.reload();
      this.$store.dispatch("fund/getFundList", this.userId);
      this.$refs.table.reload();
    },
    /* 获取文章详情 */
    getInfo() {
      if (this.data.id > 0) {
        this.$http
          .get("/packet/record/" + this.data.id)
          .then((res) => {
            if (res.data.code === 200) {
              this.form = res.data.data;
              this.isUpdate = true;
            } else {
              this.$message.error(res.data.message);
            }
          })
          .catch((e) => {
            this.$message.error(e.message);
          });
      }
    },
    /* 保存编辑 */
    save() {
      this.$refs["form"].validate((valid) => {
        if (valid) {
          this.loading = true;
          this.$http
            .post(
              this.isUpdate ? "/packet/update" : "/packet/create",
              this.form
            )
            .then((res) => {
              this.loading = false;
              if (res.data.code === 200) {
                this.$message.success(res.data.message);
                if (!this.isUpdate) {
                  this.form = {};
                }
                this.updateVisible(false);
                this.$emit("done");
              } else {
                this.$message.error(res.data.message);
              }
            })
            .catch((e) => {
              this.loading = false;
              this.$message.error(e.message);
            });
        } else {
          return false;
        }
      });
    },
    /* 更新visible */
    updateVisible(value) {
      this.$emit("update:visible", value);
    },
    /* 关闭页面 */
    close(hide) {
      if (hide) {
        hide();
      }
      this.$emit("done");
    },
  },
};
</script>

<style scoped></style>
