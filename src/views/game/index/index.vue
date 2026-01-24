<template>
  <div class="ele-body">
    <el-card shadow="never">
      <!-- 搜索表单 -->
      <el-form :model="where" label-width="77px" class="ele-form-search" @keyup.enter.native="reload"
        @submit.native.prevent>
        <el-row :gutter="15">
          <el-col :lg="3" :md="12">
            <el-form-item label="游戏ID:">
              <el-input clearable v-model="where.gameId" placeholder="请输入游戏ID" />
            </el-form-item>
          </el-col>
          <el-col :lg="4" :md="12">
            <el-form-item label="游戏名:">
              <el-input clearable v-model="where.gameName" placeholder="请输入游戏名" />
            </el-form-item>
          </el-col>
          <el-col :lg="6" :md="12">
            <div class="ele-form-actions">
              <el-button type="primary" icon="el-icon-search" class="ele-btn-icon" @click="reload">查询
              </el-button>
              <el-button @click="reset">重置</el-button>
            </div>
          </el-col>
        </el-row>
      </el-form>
      <!-- 数据表格 -->
      <ele-pro-table ref="table" :where="where" :datasource="url" :columns="columns" :selection.sync="selection">
        <!-- 表头工具栏 -->
        <template slot="toolbar">
          <el-button size="small" type="primary" icon="el-icon-plus" class="ele-btn-icon" @click="openEdit(null)">添加
          </el-button>
        </template>

        <template slot="denuvo" slot-scope="{ row }">
          <el-tag :type="row.denuvo ? 'success' : 'info'">D加密: {{ row.denuvo ? 'True' : 'False' }}</el-tag>
          <el-tag :type="row.drm ? 'success' : 'info'">DRM: {{ row.drm ? 'True' : 'False' }}</el-tag>
          <el-tag :type="row.online ? 'success' : 'info'">联机: {{ row.online ? 'True' : 'False' }}</el-tag>
          <el-tag :type="row.online_plus ? 'success' : 'info'">联机补丁: {{ row.online_plus ? 'True' : 'False' }}</el-tag>
        </template>
        <template v-slot:DLCIDs="{
          /*row*/
        }">
          <!--el-tag type="success">{{ row["dlcId"] }}</el-tag-->
          <el-tag type="success">未配置</el-tag>
          <el-tag type="success">未配置</el-tag>
          <el-tag type="success">未配置</el-tag>
          <el-tag type="success">未配置</el-tag>
        </template>
        <!-- 操作列 -->
        <template slot="action" slot-scope="{ row }">
          <div>
            <el-link type="primary" :underline="false" icon="el-icon-edit" @click="openEdit(row)">修改
            </el-link>
            <el-popconfirm class="ele-action" title="确定要删除此游戏吗？" @confirm="remove(row)">
              <el-link type="danger" slot="reference" :underline="false" icon="el-icon-delete">删除
              </el-link>
            </el-popconfirm>
          </div>
          <div>
            <el-popconfirm :disabled="row.status === 1" class="ele-action" title="确定要启用此游戏吗？" @confirm="enable(row)">
              <el-link :disabled="row.status === 1" type="success" slot="reference" :underline="false"
                icon="el-icon-check"> 启用
              </el-link>
            </el-popconfirm>
            <el-popconfirm :disabled="row.status === 0" class="ele-action" title="确定要禁用此游戏吗？" @confirm="disable(row)">
              <el-link :disabled="row.status === 0" type="warning" slot="reference" :underline="false"
                icon="el-icon-close"> 禁用
              </el-link>
            </el-popconfirm>
          </div>
        </template>
        <!-- 文章封面列 -->
        <template slot="imageUrl" slot-scope="{ row }">
          <el-avatar shape="square" :size="60" :src="row.imageUrl" />
        </template>
        <!-- 状态列 -->
        <template slot="status" slot-scope="{ row }">
          <el-tag v-if="row.status === 1" size="mini">生效中 </el-tag>
          <el-tag v-if="row.status !== 1" type="info" size="mini">已停用
          </el-tag>
        </template>
      </ele-pro-table>
    </el-card>
    <!-- 编辑弹窗 -->
    <events-edit v-if="showEdit" @close="showEdit = false" :data="current" :visible="showEdit" @done="reload" />
  </div>
</template>

<script>
import { mapGetters } from "vuex";
import EventsEdit from "./events-edit";
export default {
  name: "CfEvents",
  components: { EventsEdit },
  computed: {
    ...mapGetters(["permission", "fundList"]),
  },
  data() {
    return {
      // 表格数据接口
      url: "/game/list",
      // 表格列配置
      columns: [
        {
          prop: "gameId",
          label: "游戏ID",
          showOverflowTooltip: true,
          width: 150,
          align: "center",
        },
        {
          prop: "gameName",
          label: "游戏名称",
          showOverflowTooltip: true,
          width: 230,
          align: "center",
        },
        {
          prop: "denuvo",
          label: "配置状态",
          minWidth: 100,
          align: "center",
          slot: "denuvo",
        },
        {
          prop: "status",
          label: "状态",
          align: "center",
          width: 150,
          resizable: false,
          slot: "status",
        },
        {
          prop: "createTime",
          label: "创建时间",
          sortable: "custom",
          showOverflowTooltip: true,
          minWidth: 50,
          align: "center",
          formatter: (row, column, cellValue) => {
            const date = new Date(cellValue);
            return this.$util.toDateString(date);
          },
        },
        {
          prop: "updateTime",
          label: "更新时间",
          sortable: "custom",
          showOverflowTooltip: true,
          minWidth: 50,
          align: "center",
          formatter: (row, column, cellValue) => {
            const date = new Date(cellValue);
            return this.$util.toDateString(date);
          },
        },
        {
          columnKey: "action",
          label: "操作",
          width: 150,
          align: "center",
          resizable: false,
          slot: "action",
          fixed: "right",
        },
      ],
      // 表格搜索条件
      where: {},
      // 表格选中数据
      selection: [],
      // 当前编辑数据
      current: null,
      // 是否显示编辑弹窗
      showEdit: false,
      // 栏目列表
      cateList: [],
    };
  },
  filters: {
    fundNameById(id, fundList) {
      // 显式传入fundList
      const fund = fundList.find((item) => item.id == id);
      return fund ? fund.name : "";
    },
  },
  methods: {
    /* 刷新表格 */
    reload() {
      this.showEdit = false;
      this.$refs.table.reload();
      // this.$refs.table.reload({where: this.where});
    },
    /* 重置搜索 */
    reset() {
      this.where = {};
      this.reload();
    },
    /* 显示编辑 */
    openEdit(row) {
      this.current = row == null ? { status: 1 } : row;
      this.showEdit = true;
    },
    /* 删除 */
    remove(row) {
      const loading = this.$loading({ lock: true });
      this.$http
        .post("/cfEvents/delete", [row.id])
        .then((res) => {
          loading.close();
          if (res.data.code === 200) {
            this.$message.success(res.data.message);
            this.reload();
          } else {
            this.$message.error(res.data.message);
          }
        })
        .catch((e) => {
          loading.close();
          this.$message.error(e.message);
        });
    },
    /* 启用 */
    enable(row) {
      const loading = this.$loading({ lock: true });
      this.$http
        .post("/game/enable/" + row.id)
        .then((res) => {
          loading.close();
          if (res.data.code === 200) {
            this.$message.success(res.data.message);
            this.reload();
          } else {
            this.$message.error(res.data.message);
          }
        })
        .catch((e) => {
          loading.close();
          this.$message.error(e.message);
        });
    },
    /* 禁用 */
    disable(row) {
      const loading = this.$loading({ lock: true });
      this.$http
        .post("/game/disable/" + row.id)
        .then((res) => {
          loading.close();
          if (res.data.code === 200) {
            this.$message.success(res.data.message);
            this.reload();
          } else {
            this.$message.error(res.data.message);
          }
        })
        .catch((e) => {
          loading.close();
          this.$message.error(e.message);
        });
    },
    /* 批量删除 */
    removeBatch() {
      if (!this.selection.length) {
        this.$message.error("请至少选择一条数据");
        return;
      }
      this.$confirm("确定要删除选中的文章吗?", "提示", {
        type: "warning",
      })
        .then(() => {
          const loading = this.$loading({ lock: true });
          this.$http
            .post(
              "/cfEvents/delete",
              this.selection.map((d) => d.id)
            )
            .then((res) => {
              loading.close();
              if (res.data.code === 200) {
                this.$message.success(res.data.message);
                this.reload();
              } else {
                this.$message.error(res.data.message);
              }
            })
            .catch((e) => {
              loading.close();
              this.$message.error(e.message);
            });
        })
        .catch(() => { });
    },
    /* 更改状态 */
    editStatus(row) {
      const loading = this.$loading({ lock: true });
      let params = Object.assign({
        id: row.id,
        status: row.status,
      });
      this.$http
        .post("/cfEvents/status", params)
        .then((res) => {
          loading.close();
          if (res.data.code === 200) {
            this.$message.success(res.data.message);
          } else {
            row.status = !row.status ? 1 : 2;
            this.$message.error(res.data.message);
          }
        })
        .catch((e) => {
          loading.close();
          this.$message.error(e.message);
        });
    },
  },
};
</script>

<style scoped></style>
