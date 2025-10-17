<template>
  <div class="ele-body">
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
            <el-form-item label="红包标题:">
              <el-input
                clearable
                v-model="where.title"
                placeholder="请输入红包标题"
              />
            </el-form-item>
          </el-col>
          <el-col :lg="6" :md="12">
            <el-form-item label="状态:">
              <el-select
                clearable
                v-model="where.status"
                placeholder="全部"
                class="ele-fluid"
              >
                <el-option label="已停止" value="0" />
                <el-option label="生效中" value="1" />
                <el-option label="已过期" value="2" />
              </el-select>
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
        :selection.sync="selection"
        height="calc(100vh - 315px)"
      >
        <!-- 表头工具栏 -->
        <template slot="toolbar">
          <el-button
            size="small"
            type="primary"
            icon="el-icon-plus"
            class="ele-btn-icon"
            @click="openEdit(null)"
            >生成红包
          </el-button>
        </template>
        <template v-slot:fundId="{ row }">
          <el-tag type="success" v-if="fundList.length > 0">{{
            row["fundId"] | fundNameById(fundList)
          }}</el-tag>
        </template>
        <!-- 操作列 -->
        <template slot="action" slot-scope="{ row }">
          <el-link
            type="primary"
            :underline="false"
            icon="el-icon-edit"
            @click="openEdit(row)"
            >修改
          </el-link>
          <el-link
            type="success"
            :underline="false"
            icon="el-icon-edit"
            @click="openRecord(row)"
            >查看
          </el-link>
        </template>
        <!-- 状态列 -->
        <template slot="status" slot-scope="{ row }">
          <el-tag v-if="row.status === 0" type="danger" size="mini"
            >已停止
          </el-tag>
          <el-tag v-if="row.status === 1" size="mini">生效中 </el-tag>
          <el-tag v-if="row.status === 2" type="info" size="mini"
            >已过期
          </el-tag>
        </template>
      </ele-pro-table>
    </el-card>
    <!-- 编辑弹窗 -->
    <packet-edit
      v-if="showEdit"
      @close="showEdit = false"
      :data="current"
      :cate-list="cateList"
      :visible="showEdit"
      @done="reload"
    />
    <!-- 编辑弹窗 -->
    <packet-record
      v-if="showRecord"
      @close="showRecord = false"
      :data="current"
      :cate-list="cateList"
      :visible="showRecord"
      @done="reload"
    />
  </div>
</template>

<script>
import { mapGetters } from "vuex";
import PacketEdit from "./packet-edit";
import PacketRecord from "./packet-record";

export default {
  name: "CtxArticle",
  components: { PacketEdit, PacketRecord },
  computed: {
    ...mapGetters(["permission", "fundList"]),
  },
  data() {
    return {
      // 表格数据接口
      url: "/packet/page",
      // 表格列配置
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
          prop: "title",
          label: "红包标题",
          showOverflowTooltip: true,
          minWidth: 100,
          align: "center",
        },
        {
          prop: "description",
          label: "红包描述",
          align: "center",
          showOverflowTooltip: true,
          minWidth: 250,
        },
        {
          prop: "fundId",
          label: "关联基金",
          minWidth: 150,
          align: "center",
          slot: "fundId",
        },
        {
          prop: "type",
          label: "红包状态",
          align: "center",
          width: 150,
          resizable: false,
          slot: "status",
        },
        {
          prop: "amount",
          label: "红包金额",
          align: "center",
          width: 150,
          resizable: false,
        },
        {
          prop: "claimedAmount",
          label: "已领取金额",
          align: "center",
          width: 150,
          resizable: false,
        },
        {
          prop: "count",
          label: "红包数量",
          align: "center",
          width: 150,
          resizable: false,
        },
        {
          prop: "claimedCount",
          label: "已领取数量",
          align: "center",
          width: 150,
          resizable: false,
        },
        {
          prop: "effectiveAt",
          label: "生效时间",
          sortable: "custom",
          showOverflowTooltip: true,
          minWidth: 120,
          align: "center",
          formatter: (row, column, cellValue) => {
            if (!cellValue) return "";
            const date = new Date(cellValue);
            return isNaN(date) ? "Invalid Date" : date.toLocaleString();
          },
        },
        {
          prop: "expiredAt",
          label: "过期时间",
          sortable: "custom",
          showOverflowTooltip: true,
          minWidth: 120,
          align: "center",
          formatter: (row, column, cellValue) => {
            if (!cellValue) return "";
            const date = new Date(cellValue);
            return isNaN(date) ? "Invalid Date" : date.toLocaleString();
          },
        },
        {
          prop: "createdAt",
          label: "创建时间",
          sortable: "custom",
          showOverflowTooltip: true,
          minWidth: 120,
          align: "center",
          formatter: (row, column, cellValue) => {
            if (!cellValue) return "";
            const date = new Date(cellValue);
            return isNaN(date) ? "Invalid Date" : date.toLocaleString();
          },
        },
        {
          prop: "updatedAt",
          label: "更新时间",
          sortable: "custom",
          showOverflowTooltip: true,
          minWidth: 120,
          align: "center",
          formatter: (row, column, cellValue) => {
            if (!cellValue) return "";
            const date = new Date(cellValue);
            return isNaN(date) ? "" : date.toLocaleString();
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
      // 是否显示编辑弹窗
      showRecord: false,
      // 栏目列表
      cateList: [],
    };
  },
  mounted() {},
  filters: {
    fundNameById(id, fundList) {
      // 显式传入fundList
      const fund = fundList.find((item) => item.id == id);
      return fund ? fund.name : "无";
    },
  },
  methods: {
    /* 刷新表格 */
    reload() {
      this.showEdit = false;
      this.showRecord = false;
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
    /* 显示记录 */
    openRecord(row) {
      this.current = row == null ? { status: 1 } : row;
      console.log('-----')
      this.showRecord = true;
    },
    /* 更改状态 */
    editStatus(row) {
      const loading = this.$loading({ lock: true });
      let params = Object.assign({
        id: row.id,
        status: row.status,
      });
      this.$http
        .post("/cfNews/status", params)
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
